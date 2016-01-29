require 'test_helper'

class WorkdayVolunteerTest < ActiveSupport::TestCase
  def setup
    @project = Project.new(name: "IT")
    @project.save
    @workday = Workday.new(name: "Example", project: @project, workdate: 1.day.ago.to_s(:db))
    @workday.save
    @volunteer = Volunteer.new(first_name: "Bob", last_name: "Smith")
    @volunteer.save
    @workday_volunteer = WorkdayVolunteer.new(volunteer: @volunteer, workday: @workday, hours: 1.5)
  end

  def teardown
    @workday_volunteer.destroy
    @workday.destroy
    @volunteer.really_destroy!
    @project.destroy
  end

  test "should be valid" do
    assert @workday_volunteer.valid?
  end

  test "IDs should be present, hours not negative " do
    @workday_volunteer.volunteer = nil
    assert_not @workday_volunteer.valid?
    @workday_volunteer.volunteer = @volunteer
    @workday_volunteer.workday = nil
    assert_not @workday_volunteer.valid?
    @workday_volunteer.workday = @workday
    @workday_volunteer.hours = -1
    assert_not @workday_volunteer.valid?

  end
end
