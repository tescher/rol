require 'test_helper'

class VolunteersControllerTest < ActionController::TestCase

  def setup
    @volunteer = volunteers(:one)
    @user = users(:one)
    @admin = users(:michael)
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @volunteer
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @volunteer, volunteer: { first_name: @volunteer.first_name, last_name: @volunteer.last_name }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end


  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @volunteer
    end
    assert_redirected_to login_url
  end



end
