class AddWaiverCheckinFlagToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :waivers_at_checkin, :boolean
  end
end
