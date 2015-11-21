# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Setting.create!(id:1,
                            name: "System",
                            org_site: "http://www.example.org",
                            org_title: "Example Organization",
                            org_short_title: "EXAMPLEORG",
                            site_title: "Volunteer Management",
                            old_system_site: "http://old_example.org/index.php",
                            old_system_name: "Old System Example")

