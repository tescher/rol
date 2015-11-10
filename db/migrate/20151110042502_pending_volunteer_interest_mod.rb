class PendingVolunteerInterestMod < ActiveRecord::Migration
  def change
    add_column :pending_volunteer_interests, :pending_volunteer_id, :integer, index: true
    remove_index :pending_volunteer_interests, :volunteer_id
  end
end
