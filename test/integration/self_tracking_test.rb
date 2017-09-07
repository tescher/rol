require 'test_helper'

class SelfTrackingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @project = projects(:one)
    @workday = Workday.new(project: @project, workdate: Date.today.to_s(:db), name: "Example")
    @workday.save
  end

  def teardown
    @workday.destroy
  end

  test "should redirect to check out all" do
    log_in_as(@user)
    get self_tracking_launch_path(:check_out_all => true, :id => @workday.id), session: { user_id: @user.id }
    assert_redirected_to self_tracking_check_out_all_path
  end

end
