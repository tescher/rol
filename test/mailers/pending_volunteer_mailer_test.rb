require 'test_helper'

class PendingVolunteerMailerTest < ActionMailer::TestCase

  def setup
    @pending_volunteer = volunteers(:pending_one)
  end

  test "new pending volunteer" do
    # Send the email, then test that it got queued
    email = PendingVolunteerMailer.notification_email(@pending_volunteer).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ["no_reply@example.org"], email.from
    assert_equal ['admin@example.org'], email.to
    assert_equal 'New Pending Volunteer', email.subject
    assert_equal email.body.parts.length, 2
    assert_equal email.body.parts.collect(&:content_type), ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
    assert_equal read_fixture('notification').join, email.body.parts.find {|p| p.content_type.match /plain/}.body.raw_source.gsub(/\r/,"")
  end
end
