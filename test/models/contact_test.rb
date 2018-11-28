require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @volunteer = Volunteer.new(first_name: "Bobby", last_name: "Smith")
    @volunteer.save
    @contact = Contact.new(volunteer_id:@volunteer.id, date_time:1.day.ago.to_s(:db), contact_method_id: 1)
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
end
