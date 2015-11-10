class AddStateToPendingVolunteers < ActiveRecord::Migration
  def change
    add_column :pending_volunteers, :state, :string
  end
end
