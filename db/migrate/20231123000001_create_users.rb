class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :full_name
      t.string :timezone, default: 'UTC'
      t.boolean :active, default: true
      t.datetime :last_login_at
      
      t.timestamps
    end
    
    add_index :users, :email, unique: true
  end
end
