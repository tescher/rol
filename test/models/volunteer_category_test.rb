require 'test_helper'

class VolunteerCategoryTest < ActiveSupport::TestCase

  def setup
    @volunteer_category = VolunteerCategory.new(name: "Test")
  end

  def teardown
    @volunteer_category.destroy
  end

  test "should be valid" do
    assert @volunteer_category.valid?
  end

  test "name should be present, category doesn't matter" do
    @volunteer_category.name = "     "
    assert_not @volunteer_category.valid?
  end

  test "Volunteer Association" do
    @volunteer_category1 = volunteer_categories(:master)
    @volunteer1 = volunteers(:dependent)
    # puts "Volunteer category" + @volunteer1.volunteer_categories.first.to_s + " " + @volunteer_category1.to_s
    assert_raises(ActiveRecord::DeleteRestrictionError) {@volunteer_category1.destroy}
  end

end
