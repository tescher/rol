class AddUsersToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :user_id, :integer
    add_column :contacts, :last_edit_user_id, :integer
  end
end
