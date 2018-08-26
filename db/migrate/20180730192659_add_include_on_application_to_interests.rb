class AddIncludeOnApplicationToInterests < ActiveRecord::Migration
  def change
    add_column :interests, :include_on_application, :boolean, default: false
  end
end
