class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.jsonb :data, default: {}
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, %i[user_id read_at]
    add_index :notifications, :created_at
  end
end
