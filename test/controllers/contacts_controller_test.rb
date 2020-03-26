require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  setup do
    @contact = contacts(:one)
    @contact2 = contacts(:other_volunteer)
    @volunteer2 = volunteers(:duplicate)
    @user = users(:one)
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect create contact when not logged in" do
    assert_no_difference('Contact.count') do
      post :create, params: { contact: { date_time: @contact.date_time, volunteer_id: @contact.volunteer_id, contact_method_id: @contact.contact_method_id, user_id: @user.id, notes: @contact.notes } }
    end

    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, params: { id: @contact }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, params: { id: @contact, contact: {date_time: @contact.date_time, volunteer_id: @contact.volunteer_id, contact_method_id: @contact.contact_method_id, user_id: @user.id, notes: @contact.notes } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Contact.count' do
      delete :destroy, params: { id: @contact }
    end
    assert_redirected_to login_url
  end

#  test "Should only show contacts for this volunteer" do
#    log_in_as(@user)
#    @contact2.volunteer_id = @volunteer2.id
#    @contact2.save
#    get :index, volunteer_id: @volunteer2.id
#    puts @response.body
#    assert_select '[href=?]', edit_contact_path(@contact), {count: 0}
#    assert_select '[href=?]', edit_contact_path(@contact2), {count: 1}

#  end
end
