class AddInactiveToInterests < ActiveRecord::Migration
  def up
    add_column :interests, :inactive, :boolean, null: false, default: false
  end
  def down
    remove_column :interests, :inactive, :boolean
  end
end
