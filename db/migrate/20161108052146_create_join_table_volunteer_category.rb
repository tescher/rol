class CreateJoinTableVolunteerCategory < ActiveRecord::Migration
  def change
    create_table :volunteer_category_volunteers do |t|
      t.integer :volunteer_id, index: true
      t.integer :volunteer_category_id, index: true

      t.timestamps null: false
    end
  end
end
