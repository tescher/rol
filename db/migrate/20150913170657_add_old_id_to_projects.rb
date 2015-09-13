class AddOldIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :old_id, :string
  end
end
