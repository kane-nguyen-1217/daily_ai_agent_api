class SchedulerJob < ApplicationRecord
  belongs_to :user
  
  JOB_TYPES = %w[daily_summary crypto_check calendar_sync email_digest alert_check custom].freeze
  STATUSES = %w[success failed running pending].freeze
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :job_type, presence: true, inclusion: { in: JOB_TYPES }
  validates :schedule, presence: true, format: { 
    with: /\A(\*|[0-9,\-*\/]+)\s+(\*|[0-9,\-*\/]+)\s+(\*|[0-9,\-*\/]+)\s+(\*|[0-9,\-*\/]+)\s+(\*|[0-9,\-*\/]+)\z/,
    message: "must be a valid cron expression"
  }
  validates :last_status, inclusion: { in: STATUSES }, allow_nil: true
  
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }
  scope :by_type, ->(type) { where(job_type: type) }
  scope :due, -> { enabled.where('next_run_at <= ?', Time.current) }
  
  before_save :calculate_next_run, if: -> { schedule_changed? || enabled_changed? }
  
  def enable!
    update!(enabled: true)
  end
  
  def disable!
    update!(enabled: false)
  end
  
  def mark_as_running!
    update!(last_status: 'running', last_run_at: Time.current)
  end
  
  def mark_as_success!
    update!(last_status: 'success', last_error: nil)
    calculate_next_run
    save!
  end
  
  def mark_as_failed!(error_message)
    update!(last_status: 'failed', last_error: error_message)
    calculate_next_run
    save!
  end
  
  def run_now!
    SchedulerJobWorker.perform_async(id)
  end
  
  private
  
  def calculate_next_run
    return self.next_run_at = nil unless enabled
    
    # Parse cron expression and calculate next run time
    # This is a simplified version - in production use a gem like 'fugit'
    parts = schedule.split
    
    now = Time.current
    next_time = now + 1.day  # Simplified: next day at same time
    
    self.next_run_at = next_time
  end
end
