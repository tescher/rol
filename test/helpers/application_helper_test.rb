require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title,         SITE_TITLE
    assert_equal full_title("Help"), "Help | #{SITE_TITLE}"
  end
end