require 'test_helper'

class VolunteerTest < ActiveSupport::TestCase

  def setup
    @volunteer = Volunteer.new(first_name: "Example", last_name: "User", email: "user@example.com")
  end

  def teardown
    @volunteer.destroy
  end

  test "should be valid" do
    assert @volunteer.valid?
  end

  test "name should be present" do
    @volunteer.first_name = "     "
    assert_not @volunteer.valid?
    @volunteer.first_name = "Example"
    @volunteer.last_name = "     "
    assert_not @volunteer.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @volunteer.email = valid_address
      assert @volunteer.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @volunteer.email = invalid_address
      assert_not @volunteer.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @volunteer.email = mixed_case_email
    @volunteer.save
    assert_equal mixed_case_email.downcase, @volunteer.reload.email
  end

  test "waiver and background check dates accept valid dates" do
    waiver_date = "9/15/2015"
    background_check_date = "9/16/2015"
    @volunteer.waiver_date = waiver_date
    assert @volunteer.valid?, "Waiver date #{waiver_date} should be valid"
    @volunteer.background_check_date
    assert @volunteer.valid?, "Background check date #{background_check_date} should be valid"
  end

  test "waiver and background check dates reject invalid dates" do
    waiver_date = "9/31/2015"
    background_check_date = "9/31/2015"
    @volunteer.waiver_date = waiver_date
    assert_not @volunteer.valid?, "Waiver date #{waiver_date} should be invalid"
    @volunteer.background_check_date
    assert_not @volunteer.valid?, "Background check date #{background_check_date} should be invalid"

  end
end
