class CreateN8nWebhookLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :n8n_webhook_logs do |t|
      t.references :user, foreign_key: true
      t.string :workflow_id
      t.string :execution_id
      t.string :status  # 'pending', 'running', 'success', 'failed'
      t.json :request_payload
      t.json :response_payload
      t.text :error_message
      t.datetime :executed_at
      
      t.timestamps
    end
    
    add_index :n8n_webhook_logs, :workflow_id
    add_index :n8n_webhook_logs, :execution_id
    add_index :n8n_webhook_logs, :status
  end
end
