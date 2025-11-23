class CreateAlerts < ActiveRecord::Migration[7.0]
  def change
    create_table :alerts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :alert_type, null: false  # 'crypto_price', 'calendar_event', 'task_reminder', etc.
      t.string :title, null: false
      t.text :message
      t.string :severity, default: 'info'  # 'info', 'warning', 'critical'
      t.json :metadata
      t.boolean :acknowledged, default: false
      t.datetime :acknowledged_at
      t.boolean :sent, default: false
      t.datetime :sent_at
      
      t.timestamps
    end
    
    add_index :alerts, [:user_id, :acknowledged]
    add_index :alerts, [:user_id, :created_at]
    add_index :alerts, :alert_type
    add_index :alerts, :severity
  end
end
