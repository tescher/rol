require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title,         Utilities::Utilities.system_setting(:site_title)
    assert_equal full_title("Help"), "Help | #{Utilities::Utilities.system_setting(:site_title)}"
  end
end