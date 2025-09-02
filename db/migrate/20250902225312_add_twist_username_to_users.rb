class AddTwistUsernameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :twist_username, :string
  end
end
