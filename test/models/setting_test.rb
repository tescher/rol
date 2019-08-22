require 'test_helper'

class SettingTest < ActiveSupport::TestCase

  test "E-mail validator" do
    @settings = settings(:system)
    @settings.pending_volunteer_notify_email = "time@example.com;terri@example.com"
    assert_not @settings.valid?
    @settings.pending_volunteer_notify_email = "time@example.com,terri@example.com"
    assert @settings.valid?
  end

end
