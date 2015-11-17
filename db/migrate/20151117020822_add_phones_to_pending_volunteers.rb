class AddPhonesToPendingVolunteers < ActiveRecord::Migration
  def change
    add_column :pending_volunteers, :home_phone, :string
    add_column :pending_volunteers, :work_phone, :string
    add_column :pending_volunteers, :mobile_phone, :string

  end
end
