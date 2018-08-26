require 'test_helper'

class WaiverTest < ActiveSupport::TestCase
  def setup
    @volunteer = Volunteer.new(first_name: "Bobby", last_name: "Smith")
    @volunteer.save
    @guardian = Volunteer.new(first_name: "Robert", last_name: "Smith")
    @guardian.save
    @waiver = Waiver.new(volunteer_id:@volunteer.id, date_signed:1.day.ago.to_s(:db), adult:true)
    @waiver.save

  end

  def teardown
    @volunteer.really_destroy!
    @guardian.really_destroy!
    @waiver.really_destroy!
  end

  test "Date signed today or earlier" do
    assert @waiver.valid?
    @waiver.date_signed = Date.tomorrow.to_s(:db)
    assert_not @waiver.valid?
    @waiver.date_signed = nil
    assert_not @waiver.valid?
  end

  test "Must have birthdate or adult = true" do
    assert @waiver.valid?
    @waiver.adult = false
    assert_not @waiver.valid?
    @waiver.birthdate = 10.years.ago.to_s(:db)  # Will be valid even though not really an adult
    assert @waiver.valid?
  end

  test "Must have waiver text if e-signed" do
    assert @waiver.valid?
    @waiver.e_sign = true
    assert_not @waiver.valid?
    @waiver.waiver_text = "This is some waiver text"
    assert @waiver.valid?
  end

end
