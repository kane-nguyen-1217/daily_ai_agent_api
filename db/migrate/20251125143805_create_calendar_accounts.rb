class CreateCalendarAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :calendar_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :email
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at
      t.jsonb :meta, default: {}
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :calendar_accounts, %i[user_id provider email], unique: true
    add_index :calendar_accounts, :provider
    add_index :calendar_accounts, :active
  end
end
