# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
  end

Volunteer.create!(first_name:  "Example",
                  last_name: "Volunteer",
                email: "example@railstutorial.org")

  99.times do |n|
    first_name  = Faker::Name.first_name
    last_name = Faker::Name.last_name
    email = "example-#{n+1}@railstutorial.org"
    Volunteer.create!(first_name:  first_name,
                      last_name: last_name,
                 email: email)
  end