class CreateAutomationSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :automation_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :automation_type, null: false  # 'calendar', 'email', 'crypto', 'summary', etc.
      t.json :configuration
      t.boolean :enabled, default: true
      t.integer :priority, default: 0
      
      t.timestamps
    end
    
    add_index :automation_settings, [:user_id, :automation_type]
    add_index :automation_settings, :enabled
  end
end
