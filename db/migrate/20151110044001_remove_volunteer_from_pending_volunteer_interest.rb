class RemoveVolunteerFromPendingVolunteerInterest < ActiveRecord::Migration
  def change
    remove_column :pending_volunteer_interests, :volunteer_id
  end
end
