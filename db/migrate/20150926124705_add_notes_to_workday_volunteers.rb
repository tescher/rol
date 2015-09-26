class AddNotesToWorkdayVolunteers < ActiveRecord::Migration
  def change
    add_column :workday_volunteers, :notes, :string
  end
end
