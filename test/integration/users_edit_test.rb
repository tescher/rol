require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @admin = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name:  "",
                                    email: "foo@invalid",
                                    password:              "foo",
                                    password_confirmation: "bar" }
    assert_template 'users/edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), user: { name:  name,
                                    email: email,
                                    password:              "",
                                    password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to root_url
    @user.reload
    assert_equal @user.name,  name
    assert_equal @user.email, email
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), user: { name:  name,
                                    email: email,
                                    password:              "foobar12",
                                    password_confirmation: "foobar12" }
    assert_not flash.empty?
    assert_redirected_to root_url
    @user.reload
    assert_equal @user.name,  name
    assert_equal @user.email, email
  end

  test "successful delete as admin" do
    log_in_as(@admin)
    get edit_user_path(@user)
    assert_select 'a[href=?]', user_path(@user), method: :delete

    assert_difference 'User.count', -1 do
      delete user_path(@user)
    end

  end

  test "No delete if not admin" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_no_match 'a[href=?]', user_path(@user), method: :delete
  end


end