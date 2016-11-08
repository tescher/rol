class CreateVolunteerCategories < ActiveRecord::Migration
  def change
    create_table :volunteer_categories do |t|
      t.string :name
      t.boolean :inactive

      t.timestamps null: false
    end
  end
end
