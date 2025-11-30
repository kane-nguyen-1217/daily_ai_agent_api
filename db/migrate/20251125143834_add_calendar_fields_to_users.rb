class AddCalendarFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    # Update default timezone for existing users
    change_column_default :users, :timezone, from: 'UTC', to: 'Asia/Ho_Chi_Minh'
    add_column :users, :digest_hour, :integer, default: 8
  end
end
