# == Schema Information
# Schema version: 20251125143906
#
# Table name: alerts
#
#  id              :bigint           not null, primary key
#  acknowledged    :boolean          default(FALSE)
#  acknowledged_at :datetime
#  alert_type      :string           not null
#  message         :text
#  metadata        :json
#  sent            :boolean          default(FALSE)
#  sent_at         :datetime
#  severity        :string           default("info")
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_alerts_on_alert_type                (alert_type)
#  index_alerts_on_severity                  (severity)
#  index_alerts_on_user_id                   (user_id)
#  index_alerts_on_user_id_and_acknowledged  (user_id,acknowledged)
#  index_alerts_on_user_id_and_created_at    (user_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Alert < ApplicationRecord
  belongs_to :user
  
  ALERT_TYPES = %w[crypto_price calendar_event task_reminder email_notification custom].freeze
  SEVERITIES = %w[info warning critical].freeze
  
  validates :alert_type, presence: true, inclusion: { in: ALERT_TYPES }
  validates :title, presence: true, length: { maximum: 200 }
  validates :severity, inclusion: { in: SEVERITIES }
  
  scope :by_type, ->(type) { where(alert_type: type) }
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :acknowledged, -> { where(acknowledged: true) }
  scope :unacknowledged, -> { where(acknowledged: false) }
  scope :sent, -> { where(sent: true) }
  scope :unsent, -> { where(sent: false) }
  scope :recent, ->(limit = 20) { order(created_at: :desc).limit(limit) }
  
  def acknowledge!
    update!(acknowledged: true, acknowledged_at: Time.current)
  end
  
  def mark_as_sent!
    update!(sent: true, sent_at: Time.current)
  end
  
  def send_notification!
    return if sent?
    
    # Send via configured channels (Telegram, email, etc.)
    AlertNotificationService.send_alert(self)
    mark_as_sent!
  end
end
