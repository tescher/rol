class AddVolunteerToPendingVolunteer < ActiveRecord::Migration
  def change
    add_column :pending_volunteers, :volunteer_id, :integer
    add_index :pending_volunteers, :volunteer_id
  end
end
