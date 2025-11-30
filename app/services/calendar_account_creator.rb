class CalendarAccountCreator
  class << self
    def call(user:, provider:, token_response:, profile:)
      new(user:, provider:, token_response:, profile:).call
    end
  end

  def initialize(user:, provider:, token_response:, profile:)
    @user = user
    @provider = provider
    @token_response = token_response
    @profile = profile
  end

  def call
    calendar_account = @user.calendar_accounts.find_or_initialize_by(
      provider: @provider,
      email: @profile[:email]
    )

    calendar_account.assign_attributes(
      access_token: @token_response[:access_token],
      refresh_token: @token_response[:refresh_token],
      expires_at: calculate_expires_at(@token_response[:expires_in]),
      active: true,
      meta: calendar_account.meta.merge(
        consented_at: Time.current.iso8601,
        profile_name: @profile[:name],
        profile_picture: @profile[:picture],
        scopes: @token_response[:scope]
      )
    )

    if calendar_account.save
      Rails.logger.info("CalendarAccount created/updated: user_id=#{@user.id}, provider=#{@provider}, email=#{@profile[:email]}")
      calendar_account
    else
      Rails.logger.error("Failed to create CalendarAccount: #{calendar_account.errors.full_messages.join(', ')}")
      raise ActiveRecord::RecordInvalid, calendar_account
    end
  end

  private

  def calculate_expires_at(expires_in)
    return nil unless expires_in

    Time.current + expires_in.to_i.seconds
  end
end
