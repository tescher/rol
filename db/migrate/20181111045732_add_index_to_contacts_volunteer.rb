class AddIndexToContactsVolunteer < ActiveRecord::Migration
  def change
    add_index :contacts, :volunteer_id
  end
end
