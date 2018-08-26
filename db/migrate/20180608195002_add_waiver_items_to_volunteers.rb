class AddWaiverItemsToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :guardian_id, :integer
    add_column :volunteers, :adult, :boolean
    add_column :volunteers, :birthdate, :date
  end
end
