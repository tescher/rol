class CreateWaivers < ActiveRecord::Migration
  def change
    create_table :waivers do |t|
      t.integer :volunteer_id
      t.integer :guardian_id
      t.boolean :over_18
      t.date :birthdate
      t.date :date_signed
      t.string :waiver_text
      t.boolean :e_sign

      t.timestamps null: false
    end
  end
end
