# == Schema Information
# Schema version: 20251125143906
#
# Table name: ai_summaries
#
#  id           :bigint           not null, primary key
#  ai_model     :string
#  content      :text
#  source_data  :json
#  status       :string           default("pending")
#  summary_date :date
#  summary_type :string           not null
#  token_count  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_ai_summaries_on_status                    (status)
#  index_ai_summaries_on_summary_type              (summary_type)
#  index_ai_summaries_on_user_id                   (user_id)
#  index_ai_summaries_on_user_id_and_summary_date  (user_id,summary_date)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
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
