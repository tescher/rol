class AddFirstContactToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :first_contact_date, :date
    add_column :volunteers, :first_contact_type_id, :integer
    add_index :volunteers, :first_contact_type_id
  end
end
