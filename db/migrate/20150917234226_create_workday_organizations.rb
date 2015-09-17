class CreateWorkdayOrganizations < ActiveRecord::Migration
  def change
    create_table :workday_organizations do |t|
        t.integer :organization_id
        t.integer :workday_id
        t.integer :num_volunteers
        t.time :start_time
        t.time :end_time
        t.float :hours

        t.timestamps null: false
    end
  end
end
