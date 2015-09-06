class AddBackgroundCheckDateToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :background_check_date, :date
  end
end
