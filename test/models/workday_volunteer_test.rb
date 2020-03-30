require 'test_helper'

class WorkdayVolunteerTest < ActiveSupport::TestCase
  def setup
    @project = Project.new(name: "IT")
    @project.save
    @workday = Workday.new(name: "Example", project: @project, workdate: 1.day.ago.to_s(:db))
    @workday.save
    @volunteer = Volunteer.new(first_name: "Bob", last_name: "Smith")
    @volunteer.save
    @volunteer_2 = volunteers(:one)
    @workday_volunteer = WorkdayVolunteer.new(volunteer: @volunteer, workday: @workday, hours: 1.5)
  end

  def teardown
    @workday_volunteer.destroy
    @workday.destroy
    @volunteer.really_destroy!
    @project.homeowner_projects.destroy_all
    @project.destroy!
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

  test "Allow a donated_to field with a homeowner/volunteer id" do
    @workday_volunteer.homeowner_donated_to = nil
    assert @workday_volunteer.valid?
    @project.homeowners << @volunteer_2
    @workday_volunteer.homeowner_donated_to = @project.homeowners.first
    assert @workday_volunteer.valid?
    assert_equal @volunteer_2.id, @workday_volunteer.donated_to_id
    assert_equal @volunteer_2.id, @workday_volunteer.workday.project.homeowners.first.id
  end

end
