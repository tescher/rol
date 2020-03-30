class AddDonatedToToWorkdayVolunteer < ActiveRecord::Migration[5.2]
  def change
    add_column :workday_volunteers, :donated_to_id, :integer
  end
end
