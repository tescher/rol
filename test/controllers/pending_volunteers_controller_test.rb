require 'test_helper'

class PendingVolunteersControllerTest < ActionController::TestCase

  def setup
    @user = users(:one)
    @pending_volunteer = pending_volunteers(:one)
    @pending_volunteer2 = pending_volunteers(:two)
    @pending_volunteer3 = pending_volunteers(:three)
    @volunteer = Volunteer.new()
    @volunteer.first_name = @pending_volunteer.first_name + 'a'
    @volunteer.last_name = @pending_volunteer.last_name
    @volunteer.save!
  end

  test "should error or redirect all but post if not logged in " do
    get :show, id: @pending_volunteer
    assert_redirected_to login_url
    assert_not flash.empty?
    get :edit, id: @pending_volunteer
    assert_redirected_to login_url
    patch :update, id: @pending_volunteer, pending_volunteer: { xml: "" }
    assert_not flash.empty?
    assert_redirected_to login_url
    delete :destroy, id: @pending_volunteer
    assert_redirected_to login_url
    get :index
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should allow new even if not logged in" do
    get :new
    assert_template 'new'
  end

  test "index display" do
    log_in_as(@user)
    get :index
    assert_template 'shared/simple_index'
    pending_volunteers = PendingVolunteer.where(resolved: false)
    pending_volunteers.each do |pending_volunteer|
      assert_select 'div[href=?]', match_pending_volunteer_path(pending_volunteer)
    end
  end

  test "index display with nobody" do
    log_in_as(@user)
    @pending_volunteer.resolved = true
    @pending_volunteer.save!
    @pending_volunteer2.resolved = true
    @pending_volunteer2.save!
    @pending_volunteer3.resolved = true
    @pending_volunteer3.save!
    get :index
    assert_template 'shared/simple_index'
    assert_select 'span', /^No pending?/
  end

  test "match display" do
    log_in_as(@user)
    get :match, id: @pending_volunteer
    assert_template 'match'
    assert_select 'div[href=?]', edit_pending_volunteer_path(id: @pending_volunteer, volunteer_id: @volunteer)  # Should find at least one match
  end

  test "edit display" do
    log_in_as(@user)
    get :edit, id: @pending_volunteer
    assert_template 'edit'
  end

  test "update, set 'resolved' flag, update the volunteer" do
    log_in_as(@user)
    #invalid patch
    patch :update, id: @pending_volunteer  #First with no volunteer
    assert_not flash.empty?
    assert_redirected_to pending_volunteers_path
    #patch with first name used
    patch :update, id: @pending_volunteer, volunteer_id: @volunteer, first_name_use: true
    assert_redirected_to pending_volunteers_path
    assert_equal @pending_volunteer.first_name, @volunteer.first_name
    assert_equal @pending_volunteer.resolved, true
  end



end
