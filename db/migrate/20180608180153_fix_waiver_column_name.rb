class FixWaiverColumnName < ActiveRecord::Migration
  def change
    rename_column :waivers, :over_18, :adult
  end
end
