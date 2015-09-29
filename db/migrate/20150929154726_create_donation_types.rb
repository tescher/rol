class CreateDonationTypes < ActiveRecord::Migration
  def change
    create_table :donation_types do |t|
      t.string :name
      t.boolean :non_monetary, default: false, null: false

      t.timestamps null: false
    end
  end
end
