require 'test_helper'

class PendingVolunteersControllerTest < ActionController::TestCase

  def setup
    @user = users(:one)
    @pending_volunteer = volunteers(:pending_one)
    @pending_volunteer2 = volunteers(:pending_two)
    @pending_volunteer3 = volunteers(:pending_three)
    @volunteer = Volunteer.new()
    @volunteer.first_name = @pending_volunteer.first_name + 'a'
    @volunteer.last_name = @pending_volunteer.last_name
    @volunteer.save!
  end

  def teardown
    @volunteer.really_destroy!
  end

  test "should error or redirect all but post if not logged in " do
    get :edit, params: { id: @pending_volunteer }
    assert_redirected_to login_url
    patch :update, params: { id: @pending_volunteer, pending_volunteer: { xml: "" } }
    assert_not flash.empty?
    assert_redirected_to login_url
    delete :destroy, params: { id: @pending_volunteer }
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
    logged_in_as(@user)
    get :index
    assert_template 'shared/simple_index'
    pending_volunteers = Volunteer.pending.all
    pending_volunteers.each do |pending_volunteer|
      assert_select 'div[href=?]', match_pending_volunteer_path(pending_volunteer)
    end
  end

  test "index display with nobody" do
    logged_in_as(@user)
    @pending_volunteer.needs_review = false
    @pending_volunteer.save!
    @pending_volunteer2.needs_review = false
    @pending_volunteer2.save!
    @pending_volunteer3.needs_review = false
    @pending_volunteer3.save!
    get :index
    assert_template 'shared/simple_index'
    assert_select 'span', /^No pending?/
  end

  test "match display" do
    logged_in_as(@user)
    get :match, params: { id: @pending_volunteer }
    assert_template 'match'
    assert_select 'div[href=?]', edit_pending_volunteer_path(id: @pending_volunteer, matching_id: @volunteer)  # Should find at least one match
  end

  test "edit display" do
    logged_in_as(@user)
    get :edit, params: { id: @pending_volunteer }
    assert_redirected_to root_path
    get :edit, params: { id: @pending_volunteer, matching_id: @volunteer }
    assert_template 'edit'
  end



end
