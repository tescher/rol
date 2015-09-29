class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.date :date_received
      t.decimal :value
      t.string :ref_no
      t.string :item
      t.boolean :anonymous, default: false, null: false
      t.string :in_honor_of
      t.string :designation
      t.string :notes
      t.boolean :receipt_sent, default: false, null: false
      t.integer :volunteer_id
      t.integer :organization_id
      t.integer :donation_type_id

      t.timestamps null: false
    end
  end
end
