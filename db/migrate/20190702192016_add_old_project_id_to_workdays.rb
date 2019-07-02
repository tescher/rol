class AddOldProjectIdToWorkdays < ActiveRecord::Migration
  def change
    add_column :workdays, :old_project_id, :integer
  end
end
