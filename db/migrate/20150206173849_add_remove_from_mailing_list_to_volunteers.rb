class AddRemoveFromMailingListToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :remove_from_mailing_list, :boolean, null: false, default: false
  end
end
