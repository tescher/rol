class CreateWorkdayVolunteers < ActiveRecord::Migration
  def change
    create_table :workday_volunteers do |t|
      t.integer :volunteer_id
      t.integer :workday_id
      t.time :start_time
      t.time :end_time
      t.float :hours

      t.timestamps null: false
    end
  end
end
