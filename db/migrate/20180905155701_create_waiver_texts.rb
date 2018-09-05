class CreateWaiverTexts < ActiveRecord::Migration
  def change
    create_table :waiver_texts do |t|
      t.string :filename
      t.binary :data
      t.integer :type

      t.timestamps null: false
    end
  end
end
