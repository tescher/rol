class CreateVolunteerInterests < ActiveRecord::Migration
  def change
    create_table :volunteer_interests do |t|
      t.integer :volunteer_id
      t.integer :interest_id

      t.timestamps null: false
    end
  end
end
