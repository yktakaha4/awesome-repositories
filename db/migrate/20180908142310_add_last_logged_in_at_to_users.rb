class AddLastLoggedInAtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_logged_in_at, :datetime
  end
end
