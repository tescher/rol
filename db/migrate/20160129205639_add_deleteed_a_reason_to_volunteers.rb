class AddDeleteedAReasonToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :deleted_reason, :string
  end
end
