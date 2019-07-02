require 'test_helper'

class ProjectsMergeTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @project = projects(:one)
    @project_2 = projects(:two)
    @project_3 = projects(:three)
    @non_admin = users(:one)
  end

  test "No merges by non-admin" do
    log_in_as(@non_admin)
    get merge_projects_path
    assert_redirected_to root_url
  end

  test "unsuccessful merge" do
    log_in_as(@user)
    get merge_projects_path
    assert_template 'merge'
    post merge_projects_path @project, merge_projects: []
    assert_not flash[:error].empty?
    assert_template 'merge'
    post merge_projects_path nil, merge_projects: [@project2, @project3]
    assert_not flash[:error].empty?
    assert_template 'merge'
    post merge_projects_path "12345abc", merge_projects: [@project2, @project3]
    assert_not flash[:error].empty?
    assert_template 'merge'
  end

  test "successful merge" do
    log_in_as(@user)
    get merge_projects_path
    assert_template 'merge'
    workdays = Workday.where(project_id: @project.id)
    assert_not_nil(workdays)
    workdays_2 = Workday.where(project_id: @project_2.id)
    assert_not_nil(workdays_2)
    workdays_3 = Workday.where(project_id: @project_3.id)
    assert_not_nil(workdays_3)
    post merge_projects_path @project, merge_projects: [@project_2, @project_3], mark_inactive: true
    workdays.each {|wd|
      assert_nil Workday.find(wd.id).old_project_id
    }
    workdays_2.each {|wd|
      assert_equal Workday.find(wd.id).old_project_id, @project_2.id
      assert_equal Workday.find(wd.id).project_id, @project.id
    }
    workdays_3.each {|wd|
      assert_equal Workday.find(wd.id).old_project_id, @project_3.id
      assert_equal Workday.find(wd.id).project_id, @project.id
    }
    @project_2.reload
    assert_equal @project_2.inactive, true
    @project_3.reload
    assert_equal @project_3.inactive, true
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "friendly forwarding" do
    get merge_projects_path
    log_in_as(@user)
    assert_redirected_to merge_projects_path
  end



end