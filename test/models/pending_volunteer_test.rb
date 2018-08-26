require 'test_helper'

class PendingVolunteerTest < ActiveSupport::TestCase

  def setup
  end

  test "first and last name present" do
    @pending_volunteer = Volunteer.pending.new
    @pending_volunteer.agree_to_background_check = true
    @pending_volunteer.first_name = "     "
    assert_not @pending_volunteer.valid?
    @pending_volunteer.first_name = "Example"
    @pending_volunteer.last_name = "  "
    assert_not @pending_volunteer.valid?
    @pending_volunteer.agree_to_background_check = false
    @pending_volunteer.first_name = "Fred"
    @pending_volunteer.last_name = "Example"
    assert_not @pending_volunteer.valid?
  end

end
