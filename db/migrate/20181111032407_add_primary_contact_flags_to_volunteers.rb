class AddPrimaryContactFlagsToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :primary_employer_contact, :boolean
    add_column :volunteers, :primary_church_contact, :boolean
  end
end
