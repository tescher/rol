class CanEditUnownedContactsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_edit_unowned_contacts, :boolean, default: false
  end
end
