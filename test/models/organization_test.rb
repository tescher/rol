require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase

  def setup
    @organization_type = OrganizationType.new(name: "NGO")
    @organization_type.save
    @organization = Organization.new(name: "Example", organization_type: @organization_type)
  end

  test "should be valid" do
    assert @organization.valid?
  end

  test "name should be present, category doesn't matter" do
    @organization.name = "     "
    assert_not @organization.valid?
    @organization.name = "Example"
    @organization.organization_type = nil
    assert_not @organization.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @organization.email = valid_address
      assert @organization.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @organization.email = invalid_address
      assert_not @organization.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @organization.email = mixed_case_email
    @organization.save
    assert_equal mixed_case_email.downcase, @organization.reload.email
  end

end
