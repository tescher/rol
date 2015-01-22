class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.string :name
      t.integer :interest_category_id
      t.boolean :highlight

      t.timestamps null: false
    end
  end
end
