require 'test_helper'

class ProjectsMergeTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @project = projects(:one)
    @volunteer = volunteers(:volunteer_1)
    @project_2 = projects(:two)
    @volunteer_2 = volunteers(:volunteer_2)
    @project_3 = projects(:three)
    @volunteer_3 = volunteers(:volunteer_3)
    @workday_21 = Workday.new(project_id: @project_2.id, name: "dup", workdate: Date.yesterday)
    @workday_21.save!
    @workday_31 = Workday.new(project_id: @project_3.id, name: "dup", workdate: Date.yesterday)
    @workday_31.save!
    @workday_32 = Workday.new(project_id: @project_3.id, name: "3-2", workdate: Date.yesterday)
    @workday_32.save!
    @workday_33 = Workday.new(project_id: @project_3.id, name: "3-3", workdate: Date.yesterday)
    @workday_33.save!
    @non_admin = users(:one)
  end

  def teardown
    [@workday_21, @workday_31, @workday_32, @workday_33].each do |wd|
      wd.destroy!
    end
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
    post merge_projects_path project_id: @project.id, merge_project_ids: []
    assert_not flash[:error].empty?
    assert_template 'merge'
    post merge_projects_path project_id: nil, merge_project_ids: [@project2, @project3]
    assert_not flash[:error].empty?
    assert_template 'merge'
    post merge_projects_path project_id: "12345abc", merge_project_ids: [@project2, @project3]
    assert_not flash[:error].empty?
    assert_template 'merge'
  end

  test "no merge into same project" do
    log_in_as(@user)
    post merge_projects_path project_id: @project.id, merge_project_ids: [@project_2, @project_3, @project], mark_inactive: true
    assert_not flash[:error].empty?
    assert_template 'merge'
  end

  test "successful merge" do
    log_in_as(@user)
    get merge_projects_path
    assert_template 'merge'
    workdays = Workday.where(project_id: @project.id).load
    assert_not_nil(workdays)
    workdays_2 = Workday.where(project_id: @project_2.id).load
    assert_not_nil(workdays_2)
    workdays_3 = Workday.where(project_id: @project_3.id).load
    assert_not_nil(workdays_3)
    post merge_projects_path project_id: @project.id, merge_project_ids: [@project_2, @project_3], mark_inactive: 1
    workdays.each {|wd|
      # puts "Workday: #{wd.id} Project: #{wd.project_id}, Old project #{wd.old_project_id}"
      assert_nil Workday.find(wd.id).old_project_id
    }
    workdays_2.each {|wd|
      # puts "Workday #{wd.id} old project id #{wd.reload.old_project_id}"
      assert_equal Workday.find(wd.id).old_project_id, @project_2.id
      assert_equal Workday.find(wd.id).project_id, @project.id
    }
    workdays_3.each {|wd|
      # puts "Workday #{wd.id} old project id #{wd.reload.old_project_id}"
      assert_equal Workday.find(wd.id).old_project_id, @project_3.id
      assert_equal Workday.find(wd.id).project_id, @project.id
    }
    @project_2.reload
    assert @project_2.inactive
    @project_3.reload
    assert @project_3.inactive
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "friendly forwarding" do
    get merge_projects_path
    log_in_as(@user)
    assert_redirected_to merge_projects_path
  end

  test "Homeowners merge correctly, removing any duplicates" do
    log_in_as(@user)
    get merge_projects_path
    assert_template 'merge'
    HomeownerProject11 = HomeownerProject.create(volunteer: @volunteer, project: @project)
    HomeownerProject12 = HomeownerProject.create(volunteer: @volunteer, project: @project_2)
    HomeownerProject21 = HomeownerProject.create(volunteer: @volunteer_2, project: @project)
    HomeownerProject22 = HomeownerProject.create(volunteer: @volunteer_2, project: @project_2)
    HomeownerProject31 = HomeownerProject.create(volunteer: @volunteer_3, project: @project)
    HomeownerProject32 = HomeownerProject.create(volunteer: @volunteer_3, project: @project_2)
    post merge_projects_path project_id: @project.id, merge_project_ids: [@project_2, @project_3], mark_inactive: 1
    # after this should have all 3 volunteers as homeowners on this project, and only those three homeowners exist in the system
    assert_equal 3, HomeownerProject.count
    assert_equal 1, HomeownerProject.where(volunteer: @volunteer).count
    assert_equal 1, HomeownerProject.where(volunteer: @volunteer_2).count
    assert_equal 1, HomeownerProject.where(volunteer: @volunteer_3).count

  end



end