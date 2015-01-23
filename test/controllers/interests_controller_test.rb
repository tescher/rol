require 'test_helper'

class InterestsControllerTest < ActionController::TestCase
  def setup
    @interest = interests(:one)
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @interest
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @interest, interest: { name: @interest.name, interest_category_id: @interest.interest_category_id }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end


  test "should redirect destroy when not logged in" do
    assert_no_difference 'Interest.count' do
      delete :destroy, id: @interest
    end
    assert_redirected_to login_url
  end



end
