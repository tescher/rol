class AddNotesToPendingVolunteer < ActiveRecord::Migration
  def change
    add_column :pending_volunteers, :notes, :string
  end
end
