require 'test_helper'

class WorkdayOrganizationTest < ActiveSupport::TestCase
  def setup
    @project = Project.new(name: "IT")
    @project.save
    @workday = Workday.new(name: "Example", project: @project, workdate: 1.day.ago.to_s(:db))
    @workday.save
    @organization = Organization.new(name: "Barboo Baptist", organization_type_id: 1)
    @organization.save
    @workday_organization = WorkdayOrganization.new(organization: @organization, workday: @workday, hours: 1.5)
  end

  test "should be valid" do
    assert @workday_organization.valid?
  end

  test "IDs should be present, hours not negative " do
    @workday_organization.organization = nil
    assert_not @workday_organization.valid?
    @workday_organization.organization = @organization
    @workday_organization.workday = nil
    assert_not @workday_organization.valid?
    @workday_organization.workday = @workday
    @workday_organization.hours = -1
    assert_not @workday_organization.valid?

  end
end
