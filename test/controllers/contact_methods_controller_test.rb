require 'test_helper'

class ContactMethodsControllerTest < ActionController::TestCase
  setup do
    @contact_method = contact_methods(:one)
    @user = users(:michael)
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, params: { id: @contact_method }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, params: { id: @contact_method, contact_method: { name: "Updated Name" } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end


  test "should redirect destroy when not logged in" do
    assert_no_difference 'ContactMethod.count' do
      delete :destroy, params: { id: @contact_method }
    end
    assert_redirected_to login_url
  end


end
