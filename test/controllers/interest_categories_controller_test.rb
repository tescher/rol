require 'test_helper'

class InterestCategoriesControllerTest < ActionController::TestCase
  def setup
    @interest_category = interest_categories(:office)
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @interest_category
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @interest_category, interest_category: { name: @interest_category.name }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end


  test "should redirect destroy when not logged in" do
    assert_no_difference 'InterestCategory.count' do
      delete :destroy, id: @interest_category
    end
    assert_redirected_to login_url
  end

end
