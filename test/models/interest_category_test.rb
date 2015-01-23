require 'test_helper'

class InterestCategoryTest < ActiveSupport::TestCase

  def setup
    @interest_category = InterestCategory.new(name: "Office")
  end

  test "should be valid" do
    assert @interest_category.valid?
  end

  test "name should be present, category doesn't matter" do
    @interest_category.name = "     "
    assert_not @interest_category.valid?
  end
end
