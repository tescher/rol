class AddDeletedAtToWaiver < ActiveRecord::Migration
  def change
    add_column :waivers, :deleted_at, :datetime
    add_index :waivers, :deleted_at
  end
end
