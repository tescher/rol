require 'test_helper'

class WaiversControllerTest < ActionController::TestCase
  setup do
    @waiver = waivers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:waivers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create waiver" do
    assert_difference('Waiver.count') do
      post :create, waiver: { birthdate: @waiver.birthdate, date_signed: @waiver.date_signed, e_sign: @waiver.e_sign, guardian_id: @waiver.guardian_id, over_18: @waiver.over_18, volunteer_id: @waiver.volunteer_id, waiver_text: @waiver.waiver_text }
    end

    assert_redirected_to waiver_path(assigns(:waiver))
  end

  test "should show waiver" do
    get :show, id: @waiver
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @waiver
    assert_response :success
  end

  test "should update waiver" do
    patch :update, id: @waiver, waiver: { birthdate: @waiver.birthdate, date_signed: @waiver.date_signed, e_sign: @waiver.e_sign, guardian_id: @waiver.guardian_id, over_18: @waiver.over_18, volunteer_id: @waiver.volunteer_id, waiver_text: @waiver.waiver_text }
    assert_redirected_to waiver_path(assigns(:waiver))
  end

  test "should destroy waiver" do
    assert_difference('Waiver.count', -1) do
      delete :destroy, id: @waiver
    end

    assert_redirected_to waivers_path
  end
end
