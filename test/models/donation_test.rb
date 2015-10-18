require 'test_helper'

class DonationTest < ActiveSupport::TestCase
  def setup
    @organization = Organization.new(name: "Organization1", organization_type_id: 1)
    @organization.save
    @volunteer = Volunteer.new(first_name: "Bob", last_name: "Smith")
    @volunteer.save
    @donation_type = DonationType.new(name: "Cash", non_monetary: false)
    @donation_type_non_monetary = DonationType.new(name: "InKind", non_monetary: true)
    @donation = Donation.new(date_received: 1.day.ago.to_s(:db), value: 100, donation_type: @donation_type)
  end

  test "Needs volunteer or organization, but not both" do
    assert_not @donation.valid?
    @donation.volunteer = @volunteer
    assert @donation.valid?
    @donation.organization = @organization
    assert_not @donation.valid?
    @donation.volunteer = nil
    assert @donation.valid?
  end

  test "Needs date, type, value if monetary, and either item or value if non-monetary" do
    @donation.volunteer = @volunteer
    assert @donation.valid?

    @donation.date_received = nil
    assert_not @donation.valid?
    @donation.date_received = 1.day.ago.to_s(:db)
    assert @donation.valid?

    @donation.donation_type = nil
    assert_not @donation.valid?
    @donation.donation_type = @donation_type
    assert @donation.valid?

    @donation.value = nil
    assert_not @donation.valid?
    @donation.item = "Sofa"
    assert_not @donation.valid?
    @donation.value = 100
    assert @donation.valid?
    @donation.item = nil

    # @donation.donation_type = @donation_type_non_monetary
    # assert_not @donation.valid?
    # @donation.item = "Sofa"
    # assert @donation.valid?
    # @donation.value = nil
    # assert @donation.valid?
  end

  test "Value must be > 0 if monetary, => 0 if present and non-monetary" do
    @donation.volunteer = @volunteer
    @donation.value = -1
    assert_not @donation.valid?
    @donation.value = 0
    assert_not @donation.valid?
    @donation.donation_type = @donation_type_non_monetary
    @donation.item = "Sofa"
    @donation.value = -1
    assert_not @donation.valid?
    @donation.value = 0
    assert @donation.valid?

  end


end
