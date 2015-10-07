class AddInactiveToOrganizationTypes < ActiveRecord::Migration
  def change
    add_column :organization_types, :inactive, :boolean, default: false, null: false
  end
end
