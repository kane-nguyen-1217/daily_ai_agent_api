# == Schema Information
# Schema version: 20251125143906
#
# Table name: automation_settings
#
#  id              :bigint           not null, primary key
#  automation_type :string           not null
#  configuration   :json
#  enabled         :boolean          default(TRUE)
#  name            :string           not null
#  priority        :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_automation_settings_on_enabled                      (enabled)
#  index_automation_settings_on_user_id                      (user_id)
#  index_automation_settings_on_user_id_and_automation_type  (user_id,automation_type)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AutomationSetting < ApplicationRecord
  belongs_to :user
  
  AUTOMATION_TYPES = %w[calendar email crypto summary alert notification custom].freeze
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :automation_type, presence: true, inclusion: { in: AUTOMATION_TYPES }
  validates :priority, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :configuration, presence: true
  
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }
  scope :by_type, ->(type) { where(automation_type: type) }
  scope :ordered, -> { order(priority: :desc, created_at: :desc) }
  
  def enable!
    update!(enabled: true)
  end
  
  def disable!
    update!(enabled: false)
  end
  
  def toggle!
    update!(enabled: !enabled)
  end
end
