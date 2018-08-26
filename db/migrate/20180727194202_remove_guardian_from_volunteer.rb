class RemoveGuardianFromVolunteer < ActiveRecord::Migration
  def change
    remove_column :volunteers, :guardian_id
  end
end
