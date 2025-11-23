class CreateOauthTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :oauth_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false  # 'google', 'gmail', etc.
      t.text :access_token_ciphertext
      t.text :refresh_token_ciphertext
      t.datetime :expires_at
      t.string :scope
      t.json :token_metadata
      
      t.timestamps
    end
    
    add_index :oauth_tokens, [:user_id, :provider], unique: true
  end
end
