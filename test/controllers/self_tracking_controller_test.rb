require 'test_helper'
require "timecop"

class SelfTrackingControllerTest < ActionController::TestCase
  def setup
    @workday = workdays(:one)
    @user = users(:michael)
    @volunteer = volunteers(:one)
    @pending_volunteer = volunteers(:pending_one)
  end

  test "should redirect to home when no workday in session" do
    get :index
    assert_not flash.empty?
    assert_redirected_to root_path
  end

  test "should require authentication for launch action" do
    get :launch, id: "INTENTIONALLY_INVALID"
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should setup self-tracking session" do
    log_in_as(@user)
    assert_equal @user.id, session[:user_id]

    get :launch, id: @workday.id
    assert flash.empty?
    assert_equal @workday.id, session[:self_tracking_workday_id]
    assert_equal @user.id, session[:self_tracking_launching_user_id]
    assert_not_nil session[:self_tracking_expires_at]
  end

  test "should check self-tracking session expiration" do
    session[:self_tracking_workday_id] = @workday.id
    session[:self_tracking_launching_user_id] = @user.id

    # Missing expiration datetime
    get :index
    assert_not flash.empty?
    assert_redirected_to root_path

    # Expired session
    session[:self_tracking_expires_at] = DateTime.now - 1
    get :index
    assert_not flash.empty?
    assert_redirected_to root_path
  end

  test "should get index" do
    self.setup_self_tracking_session

    get :index
    assert_response :success
    assert_not_nil assigns(:workday)
    assert_not_nil assigns(:project)
  end

  test "should search volunteer" do
    self.setup_self_tracking_session

    # First get without any params
    get :volunteer_search
    assert_response :success

    # Empty name validation check.
    get :volunteer_search, :search_form => { name: "" }
    assert_response :success
    search_form = assigns(:search_form)
    assert search_form.errors.count > 0

    # Then try a search that expects both pending and regular volunteers
    get :volunteer_search, :search_form => { name: "Smith", phone: "(907) 745-3512Dup" }
    assert_response :success
    results = assigns(:results)
    assert_equal 3, results.count
    assert_equal "TimothyDup", results[0].first_name
    assert_equal "EscherDup", results[0].last_name
    assert_equal "(907) 745-3512Dup", results[0].home_phone
    assert_not results[0].needs_review

    assert_equal "Jane", results[1].first_name
    assert_equal "Smith", results[1].last_name
    assert results[1].needs_review

    assert_equal "Tim", results[2].first_name
    assert_equal "Smith", results[2].last_name
    assert results[2].needs_review
  end

  test "should validate check-in functionality" do
    self.setup_self_tracking_session

    # Confirm no one is checked in yet.
    assert @workday.workday_volunteers.empty?

    # Basic get
    get :check_in, id: @volunteer.id
    assert_response :success

    # Empty check-in time.
    get :check_in, id: @volunteer.id, :check_in_form => {check_in_time: ""}
    assert_response :success
    check_in_form = assigns(:check_in_form)
    assert check_in_form.errors.count > 0
    assert @workday.workday_volunteers.empty?

    # Successful check in
    get :check_in, id: @volunteer.id, :check_in_form => {check_in_time: "8:00 AM"}
    assert_response :success
    assert_equal "success", @response.body
    assert_equal 1, @workday.workday_volunteers.count
    workday_volunteer = @workday.workday_volunteers.all[0]
    assert_equal @volunteer.id, workday_volunteer.volunteer.id
    # The "date" portion is not relevant in this case so we reformat and get just the time component.
    assert_equal "08:00:00", workday_volunteer.start_time.strftime("%H:%M:%S")

    # Successful check in with pending volunteer, and a PM time to validate the 24 hours behavior
    get :check_in, id: @pending_volunteer.id, :check_in_form => {check_in_time: "5:33 PM"}
    assert_response :success
    assert_equal "success", @response.body
    assert_equal 2, @workday.workday_volunteers.count
    workday_volunteer = @workday.workday_volunteers.all[1]
    assert_equal @pending_volunteer.id, workday_volunteer.volunteer.id
    # The "date" portion is not relevant in this case so we reformat and get just the time component.
    assert_equal "17:33:00", workday_volunteer.start_time.strftime("%H:%M:%S")
  end

  test "should validate checkout functionality" do
    self.setup_self_tracking_session

    # Confirm no one is checked in yet.
    assert @workday.workday_volunteers.empty?

    # Check-in two volunteers and then check them out.
    get :check_in, id: @volunteer.id, :check_in_form => {check_in_time: "8:00 AM"}
    get :check_in, id: @pending_volunteer.id, :check_in_form => {check_in_time: "1:20 PM"}
    assert_equal 2, @workday.workday_volunteers.count

    workdate = @workday.workdate
    # Using .change so we retain the timezone.
    target_date_time = DateTime.now.change(
      :year => workdate.year, :month => workdate.month, :day => workdate.day, :hour => 17, :minute => 0
    )
    Timecop.freeze(target_date_time) do
      # Get the original records
      volunteer_workday = @workday.workday_volunteers.where(:volunteer_id => @volunteer.id)[0]
      pending_volunteer_workday = @workday.workday_volunteers.where(:volunteer_id => @pending_volunteer.id)[0]

      # Checkout
      get :checkout, workday_volunteer_id: volunteer_workday.id
      assert_not flash.empty?
      assert_redirected_to self_tracking_index_path
      updated_volunteer_workday = @workday.workday_volunteers.where(:volunteer_id => @volunteer.id)[0]
      assert_equal "08:00:00", updated_volunteer_workday.start_time.strftime("%H:%M:%S")
      assert_equal "17:00:00", updated_volunteer_workday.end_time.strftime("%H:%M:%S")
      assert_equal 9, updated_volunteer_workday.hours
      assert_equal @volunteer.id, updated_volunteer_workday.volunteer.id

      get :checkout, workday_volunteer_id: pending_volunteer_workday.id
      assert_not flash.empty?
      assert_redirected_to self_tracking_index_path
      updated_pending_volunteer_workday = @workday.workday_volunteers.where(:volunteer_id => @pending_volunteer.id)[0]
      assert_equal "13:20:00", updated_pending_volunteer_workday.start_time.strftime("%H:%M:%S")
      assert_equal "17:00:00", updated_pending_volunteer_workday.end_time.strftime("%H:%M:%S")
      assert_equal 3.7, updated_pending_volunteer_workday.hours
      assert_equal @pending_volunteer.id, updated_pending_volunteer_workday.volunteer.id
    end
  end


  def setup_self_tracking_session
    session[:self_tracking_workday_id] = @workday.id
    session[:self_tracking_expires_at] = DateTime.now + 1
    session[:self_tracking_launching_user_id] = @user.id
  end
end
