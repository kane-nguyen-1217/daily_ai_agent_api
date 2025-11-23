class AiSummary < ApplicationRecord
  belongs_to :user
  
  SUMMARY_TYPES = %w[daily weekly monthly custom].freeze
  STATUSES = %w[pending generating completed failed].freeze
  
  validates :summary_type, presence: true, inclusion: { in: SUMMARY_TYPES }
  validates :summary_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :content, presence: true, if: -> { status == 'completed' }
  
  scope :by_type, ->(type) { where(summary_type: type) }
  scope :by_date, ->(date) { where(summary_date: date) }
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :recent, -> { order(summary_date: :desc, created_at: :desc).limit(10) }
  
  def mark_as_generating!
    update!(status: 'generating')
  end
  
  def mark_as_completed!(content, token_count = nil)
    update!(
      status: 'completed',
      content: content,
      token_count: token_count
    )
  end
  
  def mark_as_failed!
    update!(status: 'failed')
  end
  
  def generate_async!
    AiSummaryWorker.perform_async(id)
  end
end
