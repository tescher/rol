class AddWaiverOptionsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :waiver_valid_days, :integer
    add_column :settings, :allow_waiver_skip, :boolean
  end
end
