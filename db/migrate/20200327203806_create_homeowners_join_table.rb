class CreateHomeownersJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_table :homeowner_projects do |t|
      t.integer :project_id
      t.integer :volunteer_id
      t.timestamps null: false
    end

    add_index :homeowner_projects, :project_id
    add_index :homeowner_projects, :volunteer_id
  end
end
