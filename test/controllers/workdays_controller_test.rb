require 'test_helper'

class WorkdaysControllerTest < ActionController::TestCase
  setup do
    @workday = workdays(:one)
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @workday
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @workday, workday: { name: @workday.name }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end


  test "should redirect destroy when not logged in" do
    assert_no_difference 'Workday.count' do
      delete :destroy, id: @workday
    end
    assert_redirected_to login_url
  end
end
