class CreateInterestCategories < ActiveRecord::Migration
  def change
    create_table :interest_categories do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
