require 'test_helper'

class WaiverTextsControllerTest < ActionController::TestCase
  setup do
    @waiver_text = waiver_texts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:waiver_texts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create waiver_text" do
    assert_difference('WaiverText.count') do
      post :create, waiver_text: { data: @waiver_text.data, filename: @waiver_text.filename, waiver_type: @waiver_text.waiver_type }
    end

    assert_redirected_to waiver_text_path(assigns(:waiver_text))
  end

  test "should show waiver_text" do
    get :show, id: @waiver_text
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @waiver_text
    assert_response :success
  end

  test "should update waiver_text" do
    patch :update, id: @waiver_text, waiver_text: { data: @waiver_text.data, filename: @waiver_text.filename, waiver_type: @waiver_text.waiver_type }
    assert_redirected_to waiver_text_path(assigns(:waiver_text))
  end

  test "should destroy waiver_text" do
    assert_difference('WaiverText.count', -1) do
      delete :destroy, id: @waiver_text
    end

    assert_redirected_to waiver_texts_path
  end
end
