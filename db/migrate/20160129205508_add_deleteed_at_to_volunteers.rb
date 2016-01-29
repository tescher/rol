class AddDeleteedAtToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :deleted_at, :datetime
    add_index :volunteers, :deleted_at
  end
end
