class AddAddressToPendingVolunteer < ActiveRecord::Migration
  def change
    add_column :pending_volunteers, :address, :string
  end
end
