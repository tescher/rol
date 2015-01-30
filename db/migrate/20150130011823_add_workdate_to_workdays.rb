class AddWorkdateToWorkdays < ActiveRecord::Migration
  def change
    add_column :workdays, :workdate, :date
  end
end
