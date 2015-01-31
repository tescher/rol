require 'test_helper'

class WorkdayTest < ActiveSupport::TestCase
  setup do
    @workday = workdays(:one)
  end
  def setup
    @project = Project.new(name: "IT")
    @project.save
    @workday = Workday.new(name: "Example", project: @project, workdate: 1.day.ago.to_s(:db))
  end

  test "should be valid" do
    assert @workday.valid?
  end

  test "name, project, and date should be present " do
    @workday.name = "     "
    assert_not @workday.valid?
    @workday.name = "Example"
    @workday.project = nil
    assert_not @workday.valid?
    @workday.project = @project
    @workday.workdate = nil
    assert_not @workday.valid?

  end

end
