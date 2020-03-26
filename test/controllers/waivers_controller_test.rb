require 'test_helper'

class WaiversControllerTest < ActionController::TestCase
  setup do
    @waiver = waivers(:one)
    @user = users(:one)
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect create waiver when not logged in" do
    assert_no_difference('Waiver.count') do
      post :create, params: { waiver: { date_signed: @waiver.date_signed, e_sign: @waiver.e_sign, guardian_id: @waiver.guardian_id, adult: @waiver.adult, volunteer_id: @waiver.volunteer_id, waiver_text: @waiver.waiver_text } }
    end

    assert_redirected_to login_url
  end

  test "should redirect show waiver when not logged in" do
    get :show, params: { id: @waiver }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, params: { id: @waiver }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, params: { id: @waiver, waiver: {date_signed: @waiver.date_signed, e_sign: @waiver.e_sign, guardian_id: @waiver.guardian_id, adult: @waiver.adult, volunteer_id: @waiver.volunteer_id, waiver_text: @waiver.waiver_text } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Waiver.count' do
      delete :destroy, params: { id: @waiver }
    end
    assert_redirected_to login_url
  end

#  test "Should only show waivers for this volunteer" do
#    log_in_as(@user)
#    @waiver2.volunteer_id = @volunteer2.id
#    @waiver2.save
#    get :index, volunteer_id: @volunteer2.id
#    puts @response.body
#    assert_select '[href=?]', edit_waiver_path(@waiver), {count: 0}
#    assert_select '[href=?]', edit_waiver_path(@waiver2), {count: 1}

#  end
end
