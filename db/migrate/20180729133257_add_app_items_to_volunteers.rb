class AddAppItemsToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :emerg_contact_name, :string
    add_column :volunteers, :emerg_contact_phone, :string
    add_column :volunteers, :medical_conditions, :string
    add_column :volunteers, :limitations, :string
    add_column :volunteers, :agree_to_background_check, :boolean
  end
end
