class CreateJoinTablePendingVolunteerInterest < ActiveRecord::Migration
  def change
      create_table :pending_volunteer_interests do |t|
      t.integer :volunteer_id, index: true
      t.integer :interest_id, index: true

      t.timestamps null: false
    end
  end
end
