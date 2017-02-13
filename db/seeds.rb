# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


require 'active_record/fixtures'

basepath = "#{Rails.root}/db/seed_fixtures"
Dir["#{basepath}/*.yml"].each do |filepath|
    basename = File.basename(filepath, ".*")
    ActiveRecord::Fixtures.create_fixtures(basepath, basename)
end
