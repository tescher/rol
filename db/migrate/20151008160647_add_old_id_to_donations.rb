class AddOldIdToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :old_id, :integer
  end
end
