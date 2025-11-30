# == Schema Information
# Schema version: 20251125143906
#
# Table name: calendar_accounts
#
#  id            :bigint           not null, primary key
#  access_token  :text
#  active        :boolean          default(TRUE)
#  email         :string
#  expires_at    :datetime
#  meta          :jsonb
#  provider      :string           not null
#  refresh_token :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_calendar_accounts_on_active                          (active)
#  index_calendar_accounts_on_provider                        (provider)
#  index_calendar_accounts_on_user_id                         (user_id)
#  index_calendar_accounts_on_user_id_and_provider_and_email  (user_id,provider,email) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class CalendarAccount < ApplicationRecord
  belongs_to :user

  # Encrypt sensitive tokens at rest
  encrypts :access_token, :refresh_token

  validates :provider, presence: true, inclusion: { in: %w[google microsoft] }
  validates :email, presence: true
  validates :user_id, uniqueness: { scope: %i[provider email] }

  scope :active, -> { where(active: true) }
  scope :google, -> { where(provider: 'google') }
  scope :microsoft, -> { where(provider: 'microsoft') }

  # Check if access token is expired
  def expired?
    return true if expires_at.nil?

    Time.current >= expires_at
  end

  # Ensure we have a valid access token, refresh if necessary
  def ensure_access_token!
    return access_token unless expired?

    refresh_access_token!
  rescue StandardError => e
    Rails.logger.error("Failed to refresh token for CalendarAccount##{id}: #{e.message}")
    mark_inactive_and_notify!
    raise
  end

  # Refresh the access token using the refresh token
  def refresh_access_token!
    case provider
    when 'google'
      refresh_google_token!
    when 'microsoft'
      refresh_microsoft_token!
    else
      raise "Unsupported provider: #{provider}"
    end
  end

  # Mark account as inactive and notify user to reconnect
  def mark_inactive_and_notify!
    update!(active: false)
    AppNotificationService.notify(
      user:,
      title: 'Calendar Reconnection Required',
      body: "Please reconnect your #{provider.titleize} calendar to continue receiving daily digests.",
      data: {
        type: 'calendar_reconnection_required',
        calendar_account_id: id,
        provider:
      }
    )
  end

  private

  def refresh_google_token!
    require 'net/http'
    require 'json'

    uri = URI('https://oauth2.googleapis.com/token')
    params = {
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      refresh_token:,
      grant_type: 'refresh_token'
    }

    response = Net::HTTP.post_form(uri, params)
    result = JSON.parse(response.body)

    raise "Google token refresh failed: #{result['error_description'] || result['error']}" unless response.code == '200'

    update!(
      access_token: result['access_token'],
      expires_at: Time.current + result['expires_in'].to_i.seconds
    )
    access_token
  end

  def refresh_microsoft_token!
    require 'net/http'
    require 'json'

    uri = URI('https://login.microsoftonline.com/common/oauth2/v2.0/token')
    params = {
      client_id: ENV['MICROSOFT_CLIENT_ID'],
      client_secret: ENV['MICROSOFT_CLIENT_SECRET'],
      refresh_token:,
      grant_type: 'refresh_token',
      scope: 'offline_access openid profile Calendars.Read'
    }

    response = Net::HTTP.post_form(uri, params)
    result = JSON.parse(response.body)

    unless response.code == '200'
      raise "Microsoft token refresh failed: #{result['error_description'] || result['error']}"
    end

    update!(
      access_token: result['access_token'],
      refresh_token: result['refresh_token'] || refresh_token, # Microsoft may return new refresh token
      expires_at: Time.current + result['expires_in'].to_i.seconds
    )
    access_token
  end
end
