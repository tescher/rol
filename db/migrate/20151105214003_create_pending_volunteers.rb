class CreatePendingVolunteers < ActiveRecord::Migration
  def change
    create_table :pending_volunteers do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :email
      t.string :city
      t.boolean :resolved, default: false, null: false
      t.string :xml
      t.string :raw

      t.timestamps null: false
    end
  end
end
