class N8nWebhookLog < ApplicationRecord
  belongs_to :user, optional: true
  
  STATUSES = %w[pending running success failed].freeze
  
  validates :workflow_id, presence: true
  validates :status, inclusion: { in: STATUSES }
  
  scope :by_workflow, ->(workflow_id) { where(workflow_id: workflow_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :successful, -> { where(status: 'success') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent, -> { order(created_at: :desc).limit(50) }
  
  def mark_as_running!
    update!(status: 'running', executed_at: Time.current)
  end
  
  def mark_as_success!(response = nil)
    update!(
      status: 'success',
      response_payload: response,
      error_message: nil
    )
  end
  
  def mark_as_failed!(error)
    update!(
      status: 'failed',
      error_message: error.to_s
    )
  end
end
