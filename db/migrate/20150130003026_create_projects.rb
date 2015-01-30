class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.boolean :inactive

      t.timestamps null: false
    end
  end
end
