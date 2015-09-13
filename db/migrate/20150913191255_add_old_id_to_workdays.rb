class AddOldIdToWorkdays < ActiveRecord::Migration
  def change
    add_column :workdays, :old_id, :string
    add_index :workdays, :old_id
  end
end
