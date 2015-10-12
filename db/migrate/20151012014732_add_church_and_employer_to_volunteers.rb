class AddChurchAndEmployerToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :church_id, :integer
    add_column :volunteers, :employer_id, :integer
    add_index :volunteers, :employer_id
    add_index :volunteers, :church_id
  end
end
