class AddNotesToWorkdayOrganizations < ActiveRecord::Migration
  def change
    add_column :workday_organizations, :notes, :string
  end
end
