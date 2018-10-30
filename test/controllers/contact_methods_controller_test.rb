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
    get :edit, id: @contact_method
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @contact_method, contact_method: { name: "Updated Name" }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end


  test "should redirect destroy when not logged in" do
    assert_no_difference 'ContactMethod.count' do
      delete :destroy, id: @contact_method
    end
    assert_redirected_to login_url
  end


  test "should get index" do
    log_in_as(@user)
    get :index
    assert_response :success
    assert_not_nil assigns(:contact_methods)
  end

  test "should get new" do
    log_in_as(@user)
    get :new
    assert_response :success
  end

  test "should create contact_method" do
    log_in_as(@user)
    assert_difference('ContactMethod.count') do
      post :create, contact_method: { inactive: @contact_method.inactive, name: @contact_method.name }
    end

    assert_redirected_to contact_method_path(assigns(:contact_method))
  end

  test "should show contact_method" do
    log_in_as(@user)
    get :show, id: @contact_method
    assert_response :success
  end

  test "should get edit" do
    log_in_as(@user)
    get :edit, id: @contact_method
    assert_response :success
  end

  test "should update contact_method" do
    log_in_as(@user)
    patch :update, id: @contact_method, contact_method: { inactive: @contact_method.inactive, name: @contact_method.name }
    assert_redirected_to contact_method_path(assigns(:contact_method))
  end

  test "should destroy contact_method" do
    log_in_as(@user)
    assert_difference('ContactMethod.count', -1) do
      delete :destroy, id: @contact_method
    end

    assert_redirected_to contact_methods_path
  end
end
