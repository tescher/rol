require 'test_helper'

class InterestTest < ActiveSupport::TestCase

  def setup
    @interest = Interest.new(name: "Example", category: "CatExample", highlight: true)
  end

  test "should be valid" do
    assert @interest.valid?
  end

  test "name should be present, category doesn't matter" do
    @interest.name = "     "
    assert_not @interest.valid?
    @interest.name = "Example"
    @interest.category = "    "
    assert @interest.valid?
  end
end
