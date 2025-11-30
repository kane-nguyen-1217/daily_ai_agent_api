# == Schema Information
# Schema version: 20251125143906
#
# Table name: n8n_webhook_logs
#
#  id               :bigint           not null, primary key
#  error_message    :text
#  executed_at      :datetime
#  request_payload  :json
#  response_payload :json
#  status           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  execution_id     :string
#  user_id          :bigint
#  workflow_id      :string
#
# Indexes
#
#  index_n8n_webhook_logs_on_execution_id  (execution_id)
#  index_n8n_webhook_logs_on_status        (status)
#  index_n8n_webhook_logs_on_user_id       (user_id)
#  index_n8n_webhook_logs_on_workflow_id   (workflow_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
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
