# db/migrate/XXXXXXXXXX_add_admin_to_users.rb
class AddAdminToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :admin, :boolean, default: false
  end
end
