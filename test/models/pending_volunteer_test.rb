require 'test_helper'

class PendingVolunteerTest < ActiveSupport::TestCase

  def setup
  end

  test "first and last name present" do
    @pending_volunteer = PendingVolunteer.new
    @pending_volunteer.first_name = "     "
    assert_not @pending_volunteer.valid?
    @pending_volunteer.first_name = "Example"
    @pending_volunteer.last_name = "  "
    assert_not @pending_volunteer.valid?
  end



end