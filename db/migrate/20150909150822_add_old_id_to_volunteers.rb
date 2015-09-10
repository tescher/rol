class AddOldIdToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :old_id, :string
    add_index :volunteers, :old_id
  end
end
