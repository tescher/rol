require 'test_helper'

class WorkdaysSearchTest < ActionDispatch::IntegrationTest

  def setup
    @user     = users(:one)
    @project = projects(:one)
    @project.save
    @workday = Workday.new(name: "Testing", project: @project, workdate: 1.day.ago.to_s(:db))
    @workday.save
  end

  test "Listing by project" do
    log_in_as(@user)
    get search_workdays_path
    projects = Project.where(inactive: false).all
    projects.each do |project|
      assert_select 'div[href=?]', workdays_path({project_id: project.id})
    end
    projects = Project.where(inactive: true).all
    projects.each do |project|
      assert_select 'div[href=?]', workdays_path({project_id: project.id}), false
    end


    assert_template 'workdays/search'
    get workdays_path, {project_id: 1}
    workdays = Workday.where(project_id: 1)
    workdays.each do |workday|
      assert_select 'div[href*=?]', add_participants_workday_path(workday)
    end
  end

end