require 'test_helper'

class VolunteerCategoriesControllerTest < ActionController::TestCase
  def setup
    @volunteer_category = volunteer_categories(:intern)
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, params: { id: @volunteer_category }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, params: { id: @volunteer_category, volunteer_category: { name: @volunteer_category.name } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end


  test "should redirect destroy when not logged in" do
    assert_no_difference 'VolunteerCategory.count' do
      delete :destroy, params: { id: @volunteer_category }
    end
    assert_redirected_to login_url
  end

end
