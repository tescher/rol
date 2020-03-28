class CreateHomeownersJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :projects, :volunteers, table_name: :homeowner_projects

    add_index :homeowner_projects, [:project_id, :volunteer_id], :unique => true
    add_index :homeowner_projects, :project_id
    add_index :homeowner_projects, :volunteer_id
  end
end
