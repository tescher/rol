require 'test_helper'

class SelfTrackingControllerTest < ActionController::TestCase
  def setup
    @workday = workdays(:one)
    @user = users(:michael)
  end

  test "should require authentication" do
    get :launch, id: "INTENTIONALLY_INVALID"
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should setup self-tracking session" do
    require "byebug"
    # byebug
    log_in_as(@user)
    puts "USER ID: #{@user.id}"
    get self_tracking_launch_path(@workday.id)
    assert flash.empty?
    assert_equal session[:self_tracking_workday_id], @workday.id
    puts "USER ID: #{session[:self_tracking_launching_user_id]}"
    assert_equal session[:self_tracking_launching_user_id], @user.id
    assert_not_empty session[:self_tracking_expires_at]
  end

  test "should expire self-tracking session" do
    session[:self_tracking_workday_id] = @workday.id
    session[:self_tracking_launching_user_id] = @user.id
    session[:self_tracking_expires_at] = DateTime.now - 1

    get :index, id: @workday.id
    assert_not flash.empty?
    assert_redirected_to root_path
  end

  test "should redirect to home when no workday in session" do
    get :index
    assert_not flash.empty?
    assert_redirected_to root_path
  end
end
