require 'test_helper'

class PendingVolunteerMailerTest < ActionMailer::TestCase

  def setup
    @pending_volunteer = volunteers(:pending_one)
  end

  test "new pending volunteer" do
    # Send the email, then test that it got queued
    email = PendingVolunteerMailer.create_notification(@pending_volunteer).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ['me@example.com'], email.from
    assert_equal ['friend@example.com'], email.to
    assert_equal 'New Pending Volunteer', email.subject
    assert_equal read_fixture('notification').join, email.body.to_s
  end
end
