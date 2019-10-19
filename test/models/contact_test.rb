require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @volunteer = Volunteer.new(first_name: "Bobby", last_name: "Smith")
    @volunteer.save
    @user = users(:one)
    @user2 = users(:two)
    @contact = Contact.new(volunteer_id:@volunteer.id, date_time:1.day.ago.to_s(:db), user_id: @user.id, last_edit_user_id: @user2.id, contact_method_id: 1)
    @contact.save

  end

  def teardown
    @volunteer.really_destroy!
    @contact.really_destroy!
  end

  test "Date contacted today or earlier" do
    assert @contact.valid?
    @contact.date_time = Date.tomorrow.to_s(:db)
    assert_not @contact.valid?
    @contact.date_time = nil
    assert_not @contact.valid?
  end

  test "Contact method null" do
    assert @contact.valid?
    @contact.contact_method_id = nil
    assert_not @contact.valid?
  end

  test "Contact user null" do
    assert_raise(ActiveRecord::RecordInvalid) {
      new_contact = Contact.new(volunteer_id:@volunteer.id, date_time:1.day.ago.to_s(:db), contact_method_id: 1)
      new_contact.save!
    }
  end

  test "Last user edit null" do
    new_contact = Contact.new(volunteer_id:@volunteer.id, date_time:1.day.ago.to_s(:db), user_id: @user.id, contact_method_id: 1)
    new_contact.save!
    assert_raise(ActiveRecord::RecordInvalid) {
      new_contact.notes = "blah"
      new_contact.save!
    }
    new_contact.last_edit_user_id = @user2.id
    new_contact.save! #should not raise an error
  end

  test "Can't delete user with associated contacts" do
    assert_raise(ActiveRecord::DeleteRestrictionError) {
      @user.destroy!
    }
    @contact.last_edit_user_id = @user.id
    @contact.user_id = @user2.id
    @contact.save!
    assert_raise(ActiveRecord::DeleteRestrictionError) {
      @user.destroy!
    }
  end
end
