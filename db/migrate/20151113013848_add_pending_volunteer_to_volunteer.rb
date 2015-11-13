class AddPendingVolunteerToVolunteer < ActiveRecord::Migration
  def change
    add_column :volunteers, :pending_volunteer_id, :integer, index: true
  end
end
