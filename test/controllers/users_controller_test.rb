require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:michael)  # Michael is an admin
    @other_user = users(:two)
    @other_user2 = users(:archer)
  end

  test "should get new" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, params: { id: @user }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, params: { id: @user, user: { name: @user.name, email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    logged_in_as(@other_user)
    get :edit, params: { id: @user }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    logged_in_as(@other_user)
    patch :update, params: { id: @user, user: { name: @user.name, email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, params: { id: @user }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    logged_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete :destroy, params: { id: @user }
    end
    assert_redirected_to root_url
  end

  test "should allow the admin attribute to be edited by an admin" do
    logged_in_as(@user)
    assert_not @other_user.admin?
    patch :update, params: { id: @other_user, user: { password:              "password",
                                            password_confirmation: "password",
                                            admin: true } }
    assert @other_user.reload.admin?
  end

  test "should not allow the admin attribute to be edited by a non-admin" do
    logged_in_as(@other_user2)
    assert_not @other_user.admin?
    patch :update, params: { id: @other_user, user: { password:              "password",
                                            password_confirmation: "password",
                                            admin: true } }
    assert_not @other_user.reload.admin?
  end

  test "should not allow the admin attribute to be edited by current user unless admin" do
    logged_in_as(@other_user)
    assert_not @other_user.admin?
    patch :update, params: { id: @other_user, user: { password:              "password",
                                            password_confirmation: "password",
                                            admin: true } }
    assert_not @other_user.reload.admin?
  end

  test "should not allow the donations attributes to be edited by current user unless admin" do
    logged_in_as(@other_user)
    assert_not @other_user.admin?
    patch :update, params: { id: @other_user, user: { password:              "password",
                                            password_confirmation: "password",
                                            all_donations: true,
                                            non_monetary_donations: false} }
    assert_not @other_user.reload.all_donations?
    patch :update, params: { id: @other_user, user: { password:              "password",
                                            password_confirmation: "password",
                                            all_donations: false,
                                            non_monetary_donations: true} }
    assert_not @other_user.reload.non_monetary_donations?
  end






end