require 'test_helper'

class WorkdayOrganizationsEditTest < ActionDispatch::IntegrationTest

  def setup
    @non_admin = users(:one)
    @project = projects(:one)
    @organization = organizations(:one)
    @workday = Workday.new(project: @project, workdate: Date.today.to_s(:db), name: "Example")
    @workday.save
  end

  def teardown
    @workday.destroy
  end

  test "successful edit with friendly forwarding" do
    get add_participants_workday_path(@workday)
    log_in_as(@non_admin)
    assert_redirected_to add_participants_workday_path(@workday)
    @workday_organization = WorkdayOrganization.new
    assert_difference "WorkdayOrganization.count", 1 do
      patch workday_path(@workday), params: { workday: { workday_organizations_attributes: {@workday_organization.id => {workday_id: @workday.id, organization_id: @organization.id, num_volunteers: 15, hours: 1.5}}} }
    end
  end

end