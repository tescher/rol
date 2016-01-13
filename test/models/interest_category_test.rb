require 'test_helper'

class InterestCategoryTest < ActiveSupport::TestCase

  def setup
    @interest_category = InterestCategory.new(name: "IT")
  end

  def teardown
    @interest_category.destroy
  end

  test "should be valid" do
    assert @interest_category.valid?
  end

  test "name should be present, category doesn't matter" do
    @interest_category.name = "     "
    assert_not @interest_category.valid?
  end

  test "Interest Association" do
    @interest_category1 = interest_categories(:master)
    @interest1 = interests(:dependent)
    assert_raises(ActiveRecord::DeleteRestrictionError) {@interest_category1.destroy}
  end

end
