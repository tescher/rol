require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  def setup
    @user = users(:michael)
    @settings =settings(:system)
    @non_admin = users(:one)
  end

  test "No edits by non-admin" do
    logged_in_as(@non_admin)
    get :edit, params: { id: @settings.id }
    assert_redirected_to root_url
  end

end
