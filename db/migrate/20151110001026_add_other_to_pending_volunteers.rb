class AddOtherToPendingVolunteers < ActiveRecord::Migration
  def change
    add_column :pending_volunteers, :zip, :string
    add_column :pending_volunteers, :phone, :string
  end
end
