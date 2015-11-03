require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = Project.new(name: "Food Pantry")
  end

  test "should be valid" do
    assert @project.valid?
  end

  test "name should be present" do
    @project.name = "     "
    assert_not @project.valid?
  end

  test "Workday Association" do
    @project = projects(:master)
    @workday = workdays(:dependent)
    assert_raises(ActiveRecord::DeleteRestrictionError) {@project.destroy}
  end

end
