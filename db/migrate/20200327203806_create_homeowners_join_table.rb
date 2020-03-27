class CreateHomeownersJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :projects, :volunteers, table_name: :homeowners_projects

    add_index :homeowners_projects, [:project_id, :volunteer_id], :unique => true
    add_index :homeowners_projects, :project_id
    add_index :homeowners_projects, :volunteer_id
  end
end
