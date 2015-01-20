class CreateVolunteers < ActiveRecord::Migration
  def change
    create_table :volunteers do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :occupation
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :email
      t.string :home_phone
      t.string :work_phone
      t.string :mobile_phone
      t.string :notes

      t.timestamps null: false
    end
  end
end
