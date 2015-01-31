class AddInactiveDefaultsToProjects < ActiveRecord::Migration
  def change
    change_column :projects, :inactive, :boolean, null: false, default: false
  end
end
