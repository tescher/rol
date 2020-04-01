require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = Project.new(name: "Food Pantry")
  end

  def teardown
    @project.destroy
  end

  test "should be valid" do
    assert @project.valid?
  end

  test "name should be present" do
    @project.name = "     "
    assert_not @project.valid?
  end

  test "Workday Association" do
    @project1 = projects(:master)
    @workday = workdays(:dependent)
    assert_no_difference 'Project.count' do
      @project1.destroy
    end
  end

end
