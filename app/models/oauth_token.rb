class OauthToken < ApplicationRecord
  belongs_to :user
  
  encrypts :access_token
  encrypts :refresh_token
  
  validates :provider, presence: true, 
            inclusion: { in: %w[google gmail calendar] }
  validates :access_token, presence: true
  validates :provider, uniqueness: { scope: :user_id }
  
  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  
  def expired?
    expires_at.present? && expires_at <= Time.current
  end
  
  def refresh_if_needed!
    return unless expired? && refresh_token.present?
    
    # Implement OAuth2 token refresh logic here
    # This would call the provider's refresh endpoint
    case provider
    when 'google', 'gmail', 'calendar'
      refresh_google_token!
    end
  end
  
  private
  
  def refresh_google_token!
    # OAuth2 refresh logic would go here
    # This is a placeholder for the actual implementation
    oauth_client = OAuth2::Client.new(
      ENV['GOOGLE_CLIENT_ID'],
      ENV['GOOGLE_CLIENT_SECRET'],
      site: 'https://accounts.google.com',
      token_url: '/o/oauth2/token'
    )
    
    token = OAuth2::AccessToken.from_hash(
      oauth_client,
      refresh_token: refresh_token
    )
    
    new_token = token.refresh!
    
    update!(
      access_token: new_token.token,
      expires_at: Time.at(new_token.expires_at)
    )
  end
end
