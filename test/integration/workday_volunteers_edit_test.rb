require 'test_helper'

class WorkdayVolunteersEditTest < ActionDispatch::IntegrationTest

  def setup
    @non_admin = users(:one)
    @project = projects(:one)
    @volunteer = volunteers(:one)
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
    @workday_volunteer = WorkdayVolunteer.new
    assert_difference "WorkdayVolunteer.count", 1 do
      patch workday_path(@workday), workday: { workday_volunteers_attributes: {@workday_volunteer.id => {workday_id: @workday.id, volunteer_id: @volunteer.id, hours: 1.5}}}
    end
  end

end