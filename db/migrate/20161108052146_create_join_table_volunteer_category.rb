class CreateJoinTableVolunteerCategory < ActiveRecord::Migration
  def up
    create_table :volunteer_category_volunteers do |t|
      t.integer :volunteer_id, index: true
      t.integer :volunteer_category_id, index: true

      t.timestamps null: false
    end
  end
  def down
    drop_table :volunteer_category_volunteers if ActiveRecord::Base.connection.table_exists? :volunteer_category_volunteers
  end
end
