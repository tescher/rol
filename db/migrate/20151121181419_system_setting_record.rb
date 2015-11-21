class SystemSettingRecord < ActiveRecord::Migration
  def up
    system_record = Setting.new id:1,
                                name: "System",
                                org_site: "http://www.example.org",
                                org_title: "Example Organization",
                                org_short_title: "EXAMPLEORG",
                                site_title: "Volunteer Management",
                                old_system_site: "http://old_example.org/index.php",
                                old_system_name: "Old System Example"
    system_record.save!
  end
  def down
    Setting.delete_all
  end
end
