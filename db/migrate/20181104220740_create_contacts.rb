class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.datetime :date_time
      t.integer :contact_method_id
      t.integer :volunteer_id
      t.string :notes

      t.timestamps null: false
    end
  end
end
