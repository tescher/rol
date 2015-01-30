class CreateWorkdays < ActiveRecord::Migration
  def change
    create_table :workdays do |t|
      t.string :description
      t.integer :project_id

      t.timestamps null: false
    end
  end
end
