require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'div[href=?]', edit_user_path(user)
    end
  end

  test "redirect index if not admin" do
    log_in_as(@non_admin)
    get users_path
    assert_redirected_to root_url
  end

end