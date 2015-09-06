class AddWaiverDateToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :waiver_date, :date
  end
end
