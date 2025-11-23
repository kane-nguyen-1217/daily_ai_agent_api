class CreateTelegramLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :telegram_links do |t|
      t.references :user, null: false, foreign_key: true
      t.string :telegram_user_id, null: false
      t.string :telegram_username
      t.string :verification_code
      t.boolean :verified, default: false
      t.datetime :verified_at
      t.boolean :active, default: true
      
      t.timestamps
    end
    
    add_index :telegram_links, :telegram_user_id, unique: true
    add_index :telegram_links, [:user_id, :active]
  end
end
