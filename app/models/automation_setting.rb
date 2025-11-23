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
