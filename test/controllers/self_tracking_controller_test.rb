require 'test_helper'
require "timecop"

class SelfTrackingControllerTest < ActionController::TestCase
  def setup
    @workday = workdays(:one)
    @user = users(:michael)
    @volunteer = volunteers(:one)
    @pending_volunteer = volunteers(:pending_one)   # Minor
    @pending_adult = volunteers(:pending_three)
  end

  test "should redirect to home when no workday in session" do
    get :index
    assert_not flash.empty?
    assert_redirected_to root_path
  end

  test "should require authentication for launch action" do
    get :launch, params: { id: "INTENTIONALLY_INVALID" }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should setup self-tracking session" do
    logged_in_as(@user)
    assert_equal @user.id, session[:user_id]

    get :launch, params: { id: @workday.id }
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
    get :volunteer_search, params: { :search_form => { name: "" } }
    assert_response :success
    search_form = assigns(:search_form)
    assert search_form.errors.count > 0

    # Then try a search that expects both pending and regular volunteers
    get :volunteer_search, params: { :search_form => { name: "Smith" } }
    assert_response :success
    results = assigns(:results)
    assert_equal 2, results.count

    assert_equal "Jane", results[0].first_name
    assert_equal "Smith", results[0].last_name
    assert results[0].needs_review

    assert_equal "Tom", results[1].first_name
    assert_equal "Smith", results[1].last_name
    assert results[1].needs_review

    # Test phone search
    get :volunteer_search, params: { :search_form => { name: "Escher,Tim", phone: "(907) 745-3512Dup" } }
    assert_response :success
    results = assigns(:results)
    assert_equal 1, results.count
    assert_equal "TimothyDup", results[0].first_name
    assert_equal "EscherDup", results[0].last_name
    assert_equal "(907) 745-3512Dup", results[0].home_phone
    assert_not results[0].needs_review

    # Test email search
    get :volunteer_search, params: { :search_form => { name: "Escher,Jim", email: "volunteer-10@example.com" } }
    assert_response :success
    results = assigns(:results)
    assert_equal 2, results.count
    assert_equal "Jim", results[0].first_name
    assert_equal "Escher", results[0].last_name
    assert_equal "tim@example.com", results[0].email
    assert_not results[0].needs_review

    assert_equal "Volunteer 10", results[1].first_name
    assert_equal "Example", results[1].last_name
    assert_equal "volunteer-10@example.com", results[1].email
    assert_not results[0].needs_review
  end

  test "should validate check-in functionality" do
    self.setup_self_tracking_session

    # Confirm no one is checked in yet.
    assert @workday.workday_volunteers.empty?

    # Basic get
    get :check_in, params: { id: @volunteer.id }
    assert_response :success

    # Empty check-in time.
    get :check_in, params: { id: @volunteer.id, :check_in_form => {check_in_time: ""} }
    assert_response :success
    check_in_form = assigns(:check_in_form)
    assert check_in_form.errors.count > 0
    assert @workday.workday_volunteers.empty?

    # Successful check in
    get :check_in, params: { id: @volunteer.id, :check_in_form => {check_in_time: "8:00 AM"} }
    assert_response :success
    assert_equal "success", @response.body
    assert_equal 1, @workday.workday_volunteers.count
    workday_volunteer = @workday.workday_volunteers.all[0]
    assert_equal @volunteer.id, workday_volunteer.volunteer.id
    # The "date" portion is not relevant in this case so we reformat and get just the time component.
    assert_equal "08:00:00", workday_volunteer.start_time.strftime("%H:%M:%S")

    # Successful check in with pending volunteer, and a PM time to validate the 24 hours behavior
    get :check_in, params: { id: @pending_volunteer.id, :check_in_form => {check_in_time: "5:33 PM"} }
    assert_response :success
    assert_equal "success", @response.body
    assert_equal 2, @workday.workday_volunteers.count
    workday_volunteer = @workday.workday_volunteers.where(:volunteer_id => @pending_volunteer.id)[0]
    assert_equal @pending_volunteer.id, workday_volunteer.volunteer.id
    # The "date" portion is not relevant in this case so we reformat and get just the time component.
    assert_equal "17:33:00", workday_volunteer.start_time.strftime("%H:%M:%S")
  end

  test "should validate complicated check-ins" do
    self.setup_self_tracking_session

    # Confirm no one is checked in yet.
    assert @workday.workday_volunteers.empty?



    # Check-in at 8am.
    get :check_in, params: { id: @volunteer.id, :check_in_form => {check_in_time: "8:00 AM"} }
    assert_response :success
    assert_equal "success", @response.body
    assert_equal 1, @workday.workday_volunteers.count
    workday_volunteer = @workday.workday_volunteers.all[0]
    assert_equal @volunteer.id, workday_volunteer.volunteer.id
    # The "date" portion is not relevant in this case so we reformat and get just the time component.
    assert_equal "08:00:00", workday_volunteer.start_time.strftime("%H:%M:%S")



    # Then try checking in at 1:40pm without checking out first. This should not be allowed.
    get :check_in, params: { id: @volunteer.id, :check_in_form => {check_in_time: "1:40 PM"} }
    assert_response :success
    check_in_form = assigns(:check_in_form)
    assert_equal 1, check_in_form.errors.count
    assert_equal "You are already checked in at this time.", check_in_form.errors.messages[:base][0]
    # Still only the last check-in
    assert_equal 1, @workday.workday_volunteers.count
    assert_equal "08:00:00", @workday.workday_volunteers.all[0].start_time.strftime("%H:%M:%S")



    # Next check in at 6am, this should be allowed. The 6am shift should stay the same.
    get :check_in, params: { id: @volunteer.id, :check_in_form => {check_in_time: "6:00 AM"} }
    assert_response :success
    assert_equal "success", @response.body

    warning_string = "Another shift starts at 8:00 am, please remember to check out this shift before 8:00 am."
    assert_equal warning_string, flash[:warning]

    # Then validate the actual shifts.
    shifts = @workday.workday_volunteers.all.order(:start_time)
    assert_equal 2, shifts.count

    earlier_shift = shifts[0]
    assert_equal "06:00:00", earlier_shift.start_time.strftime("%H:%M:%S")
    assert_nil earlier_shift.end_time

    later_shift = shifts[1]
    assert_equal @volunteer.id, later_shift.volunteer.id
    assert_equal "08:00:00", later_shift.start_time.strftime("%H:%M:%S")
    assert_nil later_shift.end_time


    # Next try checking in within the half hour of a future shift, this should set the checkout
    # time to one minute before the next shift. i.e. 5:30am
    get :check_in, params: { id: @volunteer.id, :check_in_form => {check_in_time: "5:30 AM"} }
    assert_response :success
    assert_equal "success", @response.body
    assert_equal warning_string, flash[:warning]

    # Then validate the actual shifts.
    shifts = @workday.workday_volunteers.all.order(:start_time)
    assert_equal 3, shifts.count

    earliest_shift = shifts[0]
    assert_equal "05:30:00", earliest_shift.start_time.strftime("%H:%M:%S")
    assert_nil earliest_shift.end_time

    earlier_shift = shifts[1]
    assert_equal "06:00:00", earlier_shift.start_time.strftime("%H:%M:%S")
    assert_nil earlier_shift.end_time

    later_shift = shifts[2]
    assert_equal @volunteer.id, later_shift.volunteer.id
    assert_equal "08:00:00", later_shift.start_time.strftime("%H:%M:%S")
    assert_nil later_shift.end_time
  end

  test "should validate checkout functionality" do
    self.setup_self_tracking_session

    # Confirm no one is checked in yet.
    assert @workday.workday_volunteers.empty?

    # Check-in two volunteers and then check them out.
    get :check_in, params: { id: @volunteer.id, :check_in_form => {check_in_time: "12:30 PM"} }
    get :check_in, params: { id: @volunteer.id, :check_in_form => {check_in_time: "8:00 AM"} }
    get :check_in, params: { id: @pending_volunteer.id, :check_in_form => {check_in_time: "1:20 PM"} }
    assert_equal 3, @workday.workday_volunteers.count

    workdate = @workday.workdate
    # Using .change so we retain the timezone.
    target_date_time = DateTime.now.change(
        :year => workdate.year, :month => workdate.month, :day => workdate.day, :hour => 17, :minute => 0
    )
    Timecop.freeze(target_date_time) do
      # Get the original records
      volunteer_workday = @workday.workday_volunteers.where(:volunteer_id => @volunteer.id).order(:start_time).first
      pending_volunteer_workday = @workday.workday_volunteers.where(:volunteer_id => @pending_volunteer.id).first

      # Checkout before the check-in time.
      get :check_out, params: { workday_volunteer_id: volunteer_workday.id, :check_out_form => {check_out_time: "6:00 AM"} }
      assert_response :success
      check_out_form = assigns(:check_out_form)
      assert_equal 1, check_out_form.errors.count
      assert_equal "must be after the check-in time.", check_out_form.errors.messages[:check_out_time][0]

      # Checkout after the start of next shift.
      get :check_out, params: { workday_volunteer_id: volunteer_workday.id, :check_out_form => {check_out_time: "2:00 PM"} }
      assert_response :success
      check_out_form = assigns(:check_out_form)
      assert_equal 1, check_out_form.errors.count
      assert_equal "You have another shift starting at 12:30 pm, you must check out before its start.", check_out_form.errors.messages[:base][0]

      # Valid checkout
      get :check_out, params: { workday_volunteer_id: volunteer_workday.id, :check_out_form => {check_out_time: "11:46 AM"} }
      assert_response :success
      assert_equal "success", @response.body
      assert_equal "#{@volunteer.name} successfully checked out.", flash[:success]
      updated_volunteer_workday = @workday.workday_volunteers.where(:volunteer_id => @volunteer.id).order(:start_time).first
      assert_equal "08:00:00", updated_volunteer_workday.start_time.strftime("%H:%M:%S")
      assert_equal "11:46:00", updated_volunteer_workday.end_time.strftime("%H:%M:%S")
      assert_equal 3.8, updated_volunteer_workday.hours
      assert_equal @volunteer.id, updated_volunteer_workday.volunteer.id

      get :check_out, params: { workday_volunteer_id: pending_volunteer_workday.id, :check_out_form => {check_out_time: "05:00 PM"} }
      assert_response :success
      assert_equal "success", @response.body
      assert_equal "#{@pending_volunteer.name} successfully checked out.", flash[:success]
      updated_pending_volunteer_workday = @workday.workday_volunteers.where(:volunteer_id => @pending_volunteer.id)[0]
      assert_equal "13:20:00", updated_pending_volunteer_workday.start_time.strftime("%H:%M:%S")
      assert_equal "17:00:00", updated_pending_volunteer_workday.end_time.strftime("%H:%M:%S")
      assert_equal 3.7, updated_pending_volunteer_workday.hours
      assert_equal @pending_volunteer.id, updated_pending_volunteer_workday.volunteer.id
    end
  end

  test "Self check-in with a new volunteer" do
    self.setup_self_tracking_session

    # After search, simulate click on "New Volunteer"
    old_controller = @controller
    @controller = PendingVolunteersController.new
    get :new, params: { launched_from_self_tracking: "yes" }
    assert_template :new
    assert_select 'form[action=?]', pending_volunteers_path(launched_from_self_tracking: "yes")
    @controller = old_controller

    # With new adult volunteer, should bring up waiver check with an adult waiver type
    get :check_in, params: { id: @pending_adult.id }
    assert_template :_need_waiver
    assert_select "#need_waiver_form_waiver_type" do
      assert_select "[value=?]", "0"  #Adult waiver
    end

    # With new minor volunteer, should bring up a guardian search and set session variable to save original volunteer
    get :check_in, params: { id: @pending_volunteer.id }
    assert_template :_guardian_search
    assert_equal session[:check_in_volunteer], @pending_volunteer.id


    # After guardian search, simulate click on "New Volunteer"
    old_controller = @controller
    @controller = PendingVolunteersController.new
    get :new, params: { launched_from_self_tracking: "yes"}
    assert_template :new
    assert_select 'form[action=?]', pending_volunteers_path({launched_from_self_tracking: "yes"})
    @controller = old_controller
    assert_equal session[:check_in_volunteer], @pending_volunteer.id

    # Now we are returning from pending volunteer creation with original minor volunteer stored in session
    get :check_in, params: { id: @pending_adult.id }
    assert_template :_need_waiver
    assert_select "#need_waiver_form_waiver_type" do
      assert_select "[value=?]", "1"  # Minor waiver
    end
    assert_nil session[:check_in_volunteer]  # Should have been reset afterward

  end


  def setup_self_tracking_session
    session[:check_in_volunteer] = nil
    session[:self_tracking_workday_id] = @workday.id
    session[:self_tracking_expires_at] = DateTime.now + 1
    session[:self_tracking_launching_user_id] = @user.id
  end
end
