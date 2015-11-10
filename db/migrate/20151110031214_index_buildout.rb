class IndexBuildout < ActiveRecord::Migration
  def change
    add_index :donations, :volunteer_id
    add_index :donations, :organization_id
    add_index :donations, :donation_type_id

    add_index :interests, :interest_category_id

    add_index :organizations, :organization_type_id

    add_index :projects, :old_id

    add_index :volunteer_interests, :volunteer_id
    add_index :volunteer_interests, :interest_id

    add_index :workday_organizations, :organization_id
    add_index :workday_organizations, :workday_id

    add_index :workday_volunteers, :volunteer_id
    add_index :workday_volunteers, :workday_id

    add_index :workdays, :project_id

  end
end
