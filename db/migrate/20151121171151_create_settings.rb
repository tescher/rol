class CreateSettings < ActiveRecord::Migration
  def up
    create_table :settings do |t|
      t.string :name
      t.string :site_title
      t.string :org_title
      t.string :org_short_title
      t.string :org_site
      t.string :old_system_site
      t.string :old_system_name
      t.boolean :no_pagination
      t.integer :records_per_page
      t.integer :min_password_length

      t.timestamps null: false
    end
  end
  def down
    drop_table :settings
  end

end
