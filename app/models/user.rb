class User < ApplicationRecord
  has_secure_password
  
  has_many :oauth_tokens, dependent: :destroy
  has_many :telegram_links, dependent: :destroy
  has_many :automation_settings, dependent: :destroy
  has_many :scheduler_jobs, dependent: :destroy
  has_many :ai_summaries, dependent: :destroy
  has_many :alerts, dependent: :destroy
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  validates :full_name, length: { maximum: 100 }, allow_blank: true
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }, allow_blank: true
  
  before_save :downcase_email
  
  def update_last_login!
    update_column(:last_login_at, Time.current)
  end
  
  private
  
  def downcase_email
    self.email = email.downcase if email.present?
  end
end
