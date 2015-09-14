require 'test_helper'

class OrganizationTypesControllerTest < ActionController::TestCase
  def setup
    @organization_type = organization_types(:church)
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @organization_type
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @organization_type, organization_type: { name: @organization_type.name }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end


  test "should redirect destroy when not logged in" do
    assert_no_difference 'OrganizationType.count' do
      delete :destroy, id: @organization_type
    end
    assert_redirected_to login_url
  end

end
