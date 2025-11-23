class CreateAiSummaries < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_summaries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :summary_type, null: false  # 'daily', 'weekly', 'monthly', 'custom'
      t.date :summary_date
      t.text :content
      t.json :source_data
      t.string :ai_model  # 'gpt-4', 'gpt-3.5-turbo', etc.
      t.integer :token_count
      t.string :status, default: 'pending'  # 'pending', 'generating', 'completed', 'failed'
      
      t.timestamps
    end
    
    add_index :ai_summaries, [:user_id, :summary_date]
    add_index :ai_summaries, :summary_type
    add_index :ai_summaries, :status
  end
end
