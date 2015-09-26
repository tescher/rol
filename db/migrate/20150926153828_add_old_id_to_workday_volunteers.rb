class AddOldIdToWorkdayVolunteers < ActiveRecord::Migration
  def change
    add_column :workday_volunteers, :old_id, :string
    add_index :workday_volunteers, :old_id
  end
end
