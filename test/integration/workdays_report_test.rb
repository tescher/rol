require 'test_helper'

class WorkdaysReportTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @project1 = Project.new(name: "Build #1", id: 1000) # Put id in here to ensure creation order
    @project1.save
    @project2 = Project.new(name: "Build #2", id: 2000)
    @project2.save
    @project3 = Project.new(name: "Build #3", id: 3000)
    @project3.save
    @project4 = Project.new(name: "Build #4", id: 4000)
    @project4.save
    @workday1 = Workday.new(name: "Workday #1", project: @project1, workdate: 6.days.ago.to_s(:db), id: 1000)
    @workday1.save
    @workday2 = Workday.new(name: "Workday #2", project: @project1, workdate: 5.days.ago.to_s(:db), id: 2000)
    @workday2.save
    @workday3 = Workday.new(name: "Workday #3", project: @project2, workdate: 4.days.ago.to_s(:db), id: 3000)
    @workday3.save
    @workday4 = Workday.new(name: "Workday #4", project: @project2, workdate: 3.days.ago.to_s(:db), id: 4000)
    @workday4.save
    @workday5 = Workday.new(name: "Workday #5", project: @project3, workdate: 2.days.ago.to_s(:db), id: 5000)
    @workday5.save
    @workday6 = Workday.new(name: "Workday #6", project: @project4, workdate: 1.days.ago.to_s(:db), id: 6000)
    @workday6.save
    @workday7 = Workday.new(name: "Workday #7", project: @project4, workdate: 7.days.ago.to_s(:db), id: 7000)
    @workday7.save
    @volunteer1 = Volunteer.new(first_name: "Volunteer", last_name: " #1")
    @volunteer1.save
    @volunteer2 = Volunteer.new(first_name: "Volunteer", last_name: " #2")
    @volunteer2.save
    @volunteer3 = Volunteer.new(first_name: "Volunteer", last_name: " #3")
    @volunteer3.save
    @volunteer4 = Volunteer.new(first_name: "Volunteer", last_name: " #4")
    @volunteer4.save
    @volunteer5 = Volunteer.new(first_name: "Volunteer", last_name: " #5")
    @volunteer5.save
    @volunteer6 = Volunteer.new(first_name: "Volunteer", last_name: " #6")
    @volunteer6.save
    @organization1 = Organization.new(name: "Organization #1", organization_type_id: 1)
    @organization1.save
    @organization2 = Organization.new(name: "Organization #2", organization_type_id: 1)
    @organization2.save
    @organization3 = Organization.new(name: "Organization #3", organization_type_id: 1)
    @organization3.save

    # Build #1, Volunteers: 2, Shifts: 4, Hours: 18.0, Orgs: 1, Org Hours: 4x14 = 56.0
    # First workday - Build #1, Volunteers: 2, Shifts: 2, Hours: 3, Orgs: 1, Org Hours: 4x14 = 56
    @workday1_volunteer1 = WorkdayVolunteer.new(volunteer: @volunteer1, workday: @workday1, hours: 2)
    @workday1_volunteer1.save
    @workday1_volunteer2 = WorkdayVolunteer.new(volunteer: @volunteer2, workday: @workday1, hours: 1)
    @workday1_volunteer2.save
    @workday1_organization1 = WorkdayOrganization.new(organization: @organization1, workday: @workday1, num_volunteers: 14, hours: 4)
    @workday1_organization1.save

    # Second workday - Build #1, Volunteers: 1, Shifts: 2, Hours: 15, Orgs: 0, Org Hours: 0
    @workday2_volunteer1a = WorkdayVolunteer.new(volunteer: @volunteer1, workday: @workday2, hours: 7)
    @workday2_volunteer1a.save
    @workday2_volunteer1b = WorkdayVolunteer.new(volunteer: @volunteer1, workday: @workday2, hours: 8)
    @workday2_volunteer1b.save

    # Third workday - Build #2, Volunteers: 1, Shifts: 1, Hours: 12, Orgs: 0, Org Hours: 0
    @workday3_volunteer3 = WorkdayVolunteer.new(volunteer: @volunteer3, workday: @workday3, hours: 12)
    @workday3_volunteer3.save

    # Fourth workday - Build #2, Volunteers: 0, Shifts: 0, Hours: 0, Orgs: 1, Org Hours: 5x2 = 10
    @workday4_organization2 = WorkdayOrganization.new(organization: @organization2, workday: @workday4, num_volunteers: 5, hours: 2)
    @workday4_organization2.save

    # Fifth workday - Build #3, Volunteers: 0, Shifts: 0, Hours: 0, Orgs: 1, Org Hours: 6x1 = 6
    @workday5_organization3 = WorkdayOrganization.new(organization: @organization3, workday: @workday5, num_volunteers: 6, hours: 1)
    @workday5_organization3.save

    # Sixth workday - Build #4, Volunteers: 2, Shifts: 2, Hours: 5, Orgs: 0, Org Hours: 0
    @workday6_volunteer1 = WorkdayVolunteer.new(volunteer: @volunteer1, workday: @workday6, hours: 2)
    @workday6_volunteer1.save
    @workday6_volunteer4 = WorkdayVolunteer.new(volunteer: @volunteer4, workday: @workday6, hours: 3)
    @workday6_volunteer4.save

    # Seventh workday - Build #4, Volunteers: 2, Shifts: 2, Hours: 17, Orgs: 0, Org Hours: 0 - Outside date range
    @workday7_volunteer5 = WorkdayVolunteer.new(volunteer: @volunteer5, workday: @workday7, hours: 8)
    @workday7_volunteer5.save
    @workday7_volunteer6 = WorkdayVolunteer.new(volunteer: @volunteer6, workday: @workday7, hours: 9)
    @workday7_volunteer6.save

    @volunteer_category = VolunteerCategory.new(name: "VC #1")
    @volunteer_category.save

  end

  def teardown
    @workday1_volunteer1.destroy
    @workday1_volunteer2.destroy
    @workday2_volunteer1a.destroy
    @workday2_volunteer1b.destroy
    @workday3_volunteer3.destroy
    @workday4_organization2.destroy
    @workday5_organization3.destroy
    @workday6_volunteer1.destroy
    @workday6_volunteer4.destroy
    @workday7_volunteer5.destroy
    @workday7_volunteer6.destroy
    @volunteer1.destroy
    @volunteer2.destroy
    @volunteer3.destroy
    @volunteer4.destroy
    @volunteer5.destroy
    @volunteer6.destroy
    @organization1.destroy
    @organization2.destroy
    @organization3.destroy
    @workday1.destroy
    @workday2.destroy
    @workday3.destroy
    @workday4.destroy
    @workday5.destroy
    @workday6.destroy
    @workday7.destroy
    @project1.destroy
    @project2.destroy
    @project3.destroy
    @project4.destroy

    @volunteer_category.destroy

  end


  test "Report without login" do
    get report_workdays_path(report_type: 1, report_format:1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")
    log_in_as(@user)
    assert_redirected_to report_workdays_path(report_type: 1, report_format:1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")
  end

  test "Workdays by Project HTML Report" do
    log_in_as(@user)
    get report_workdays_path(report_type: 1, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")

    assert_select("div.container h4:nth-of-type(1)", "Project: Build #1")
    assert_select("div.container h5:nth-of-type(1)", "Distinct Project Volunteers: 2, Volunteer Shifts: 4, Volunteer Hours: 18.0")
    assert_select("div.container h5:nth-of-type(2)", "Distinct Project Organizations: 1, Organization Hours: 56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "2")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "3.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "1")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "2")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "15.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "0")

    assert_select("div.container h4:nth-of-type(2)", "Project: Build #2")
    assert_select("div.container h5:nth-of-type(3)", "Distinct Project Volunteers: 1, Volunteer Shifts: 1, Volunteer Hours: 12.0")
    assert_select("div.container h5:nth-of-type(4)", "Distinct Project Organizations: 1, Organization Hours: 10.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "1")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "12.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "1")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "10.0")

    assert_select("div.container h4:nth-of-type(3)", "Project: Build #4")
    assert_select("div.container h5:nth-of-type(5)", "Distinct Project Volunteers: 2, Volunteer Shifts: 2, Volunteer Hours: 5.0")
    assert_select("div.container h5:nth-of-type(6)", "Distinct Project Organizations: 0, Organization Hours: 0")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "2")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "5.0")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "0")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "0")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", false)
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", false)
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", false)
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", false)

    assert_select("div.container h4:nth-of-type(4)", "Project: Build #3")
    assert_select("div.container h5:nth-of-type(7)", "Distinct Project Volunteers: 0, Volunteer Shifts: 0, Volunteer Hours: 0")
    assert_select("div.container h5:nth-of-type(8)", "Distinct Project Organizations: 1, Organization Hours: 6.0")
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "0")
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "0")
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "1")
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "6.0")
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", false)
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", false)
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", false)
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", false)

    assert_select("div.container h4:nth-of-type(6)", "Distinct Volunteers: 4 Volunteer Shifts: 7 Volunteer Hours: 35.0")
    assert_select("div.container h4:nth-of-type(7)", "Distinct Organizations: 3 Organization Hours: 72.0")

  end

  test "Participants by Project HTML Report" do
    log_in_as(@user)
    get report_workdays_path(report_type: 2, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")
    # puts "Workday Report Response: " + @response.body

    assert_select("div.container h4:nth-of-type(1)", "Project: Build #1")
    assert_select("div.container h5:nth-of-type(1)", "Distinct Project Volunteers: 2, Volunteer Shifts: 4, Volunteer Hours: 18.0")
    assert_select("div.container h5:nth-of-type(2)", "Distinct Project Organizations: 1, Organization Hours: 56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "17.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "1.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "56.0")

    assert_select("div.container h4:nth-of-type(2)", "Project: Build #2")
    assert_select("div.container h5:nth-of-type(3)", "Distinct Project Volunteers: 1, Volunteer Shifts: 1, Volunteer Hours: 12.0")
    assert_select("div.container h5:nth-of-type(4)", "Distinct Project Organizations: 1, Organization Hours: 10.0")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "12.0")
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "10.0")

    assert_select("div.container h4:nth-of-type(3)", "Project: Build #4")
    assert_select("div.container h5:nth-of-type(5)", "Distinct Project Volunteers: 2, Volunteer Shifts: 2, Volunteer Hours: 5.0")
    assert_select("div.container ul.listing:nth-of-type(5) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "3.0")
    assert_select("div.container ul.listing:nth-of-type(5) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "2.0")

    assert_select("div.container h4:nth-of-type(4)", "Project: Build #3")
    assert_select("div.container h5:nth-of-type(6)", "Distinct Project Organizations: 1, Organization Hours: 6.0")
    assert_select("div.container ul.listing:nth-of-type(6) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "6.0")

    assert_select("div.container h4:nth-of-type(6)", "Distinct Volunteers: 4 Volunteer Shifts: 7 Volunteer Hours: 35.0")
    assert_select("div.container h4:nth-of-type(7)", "Distinct Organizations: 3 Organization Hours: 72.0")

  end

  test "Hours by Participant HTML Report" do
    log_in_as(@user)
    get report_workdays_path(report_type: 3, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")

    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "19.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "12.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "3.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(4) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "1.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(5) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(6) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)

    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "10.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "6.0")

  end

  test "Workdays by Project HTML Report, filter on project" do
    log_in_as(@user)
    get report_workdays_path(report_type: 1, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "", project_ids: [@project1.id, @project2.id])

    assert_select("div.container h4:nth-of-type(1)", "Project: Build #1")
    assert_select("div.container h5:nth-of-type(1)", "Distinct Project Volunteers: 2, Volunteer Shifts: 4, Volunteer Hours: 18.0")
    assert_select("div.container h5:nth-of-type(2)", "Distinct Project Organizations: 1, Organization Hours: 56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "2")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "3.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "1")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "2")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "15.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "0")

    assert_select("div.container h4:nth-of-type(2)", "Project: Build #2")
    assert_select("div.container h5:nth-of-type(3)", "Distinct Project Volunteers: 1, Volunteer Shifts: 1, Volunteer Hours: 12.0")
    assert_select("div.container h5:nth-of-type(4)", "Distinct Project Organizations: 1, Organization Hours: 10.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "1")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "12.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "1")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "10.0")

    assert_select("div.container h4:nth-of-type(4)", "Distinct Volunteers: 3 Volunteer Shifts: 5 Volunteer Hours: 30.0")
    assert_select("div.container h4:nth-of-type(5)", "Distinct Organizations: 2 Organization Hours: 66.0")

  end

  test "Participants by Project HTML Report, filter on project" do
    log_in_as(@user)
    get report_workdays_path(report_type: 2, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "", project_ids: [@project1.id, @project2.id])

    assert_select("div.container h4:nth-of-type(1)", "Project: Build #1")
    assert_select("div.container h5:nth-of-type(1)", "Distinct Project Volunteers: 2, Volunteer Shifts: 4, Volunteer Hours: 18.0")
    assert_select("div.container h5:nth-of-type(2)", "Distinct Project Organizations: 1, Organization Hours: 56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "17.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "1.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "56.0")

    assert_select("div.container h4:nth-of-type(2)", "Project: Build #2")
    assert_select("div.container h5:nth-of-type(3)", "Distinct Project Volunteers: 1, Volunteer Shifts: 1, Volunteer Hours: 12.0")
    assert_select("div.container h5:nth-of-type(4)", "Distinct Project Organizations: 1, Organization Hours: 10.0")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "12.0")
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "10.0")

    assert_select("div.container h4:nth-of-type(4)", "Distinct Volunteers: 3 Volunteer Shifts: 5 Volunteer Hours: 30.0")
    assert_select("div.container h4:nth-of-type(5)", "Distinct Organizations: 2 Organization Hours: 66.0")

  end

  test "Hours by Participant HTML Report, filter on project" do
    log_in_as(@user)
    get report_workdays_path(report_type: 3, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "", project_ids: [@project1.id, @project2.id])

    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "17.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "12.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "1.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(4) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(5) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(6) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)

    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "10.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", false)

  end

  test "Workdays by Project HTML Report, filter on volunteer category and project" do
    log_in_as(@user)
    @volunteer1.volunteer_categories = [@volunteer_category]
    @volunteer1.save
    get report_workdays_path(report_type: 1, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "", volunteer_category_ids: [@volunteer_category.id], project_ids: [@project1.id, @project2.id])

    assert_select("div.container h4:nth-of-type(1)", "Project: Build #1")
    assert_select("div.container h5:nth-of-type(1)", "Distinct Project Volunteers: 1, Volunteer Shifts: 3, Volunteer Hours: 17.0")
    assert_select("div.container h5:nth-of-type(2)", "Distinct Project Organizations: 1, Organization Hours: 56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "1")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "2.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "1")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "2")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "15.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "0")

    assert_select("div.container h4:nth-of-type(2)", "Project: Build #2")
    assert_select("div.container h5:nth-of-type(3)", "Distinct Project Volunteers: 0, Volunteer Shifts: 0, Volunteer Hours: 0")
    assert_select("div.container h5:nth-of-type(4)", "Distinct Project Organizations: 1, Organization Hours: 10.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "1")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "10.0")

    assert_select("div.container h4:nth-of-type(4)", "Distinct Volunteers: 1 Volunteer Shifts: 3 Volunteer Hours: 17.0")
    assert_select("div.container h4:nth-of-type(5)", "Distinct Organizations: 2 Organization Hours: 66.0")

  end

  test "Participants by Project HTML Report, filter on volunteer category and project" do
    log_in_as(@user)
    @volunteer1.volunteer_categories = [@volunteer_category]
    @volunteer1.save
    get report_workdays_path(report_type: 2, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "", volunteer_category_ids: [@volunteer_category.id], project_ids: [@project1.id, @project2.id])

    assert_select("div.container h4:nth-of-type(1)", "Project: Build #1")
    assert_select("div.container h5:nth-of-type(1)", "Distinct Project Volunteers: 1, Volunteer Shifts: 3, Volunteer Hours: 17.0")
    assert_select("div.container h5:nth-of-type(2)", "Distinct Project Organizations: 1, Organization Hours: 56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "17.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "56.0")

    assert_select("div.container h4:nth-of-type(2)", "Project: Build #2")
    assert_select("div.container h5:nth-of-type(3)", "Distinct Project Organizations: 1, Organization Hours: 10.0")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "10.0")

    assert_select("div.container h4:nth-of-type(4)", "Distinct Volunteers: 1 Volunteer Shifts: 3 Volunteer Hours: 17.0")
    assert_select("div.container h4:nth-of-type(5)", "Distinct Organizations: 2 Organization Hours: 66.0")

  end

  test "Hours by Participant HTML Report, filter on volunteer category and project" do
    log_in_as(@user)
    @volunteer1.volunteer_categories = [@volunteer_category]
    @volunteer1.save
    get report_workdays_path(report_type: 3, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "", volunteer_category_ids: [@volunteer_category.id], project_ids: [@project1.id, @project2.id])

    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", "17.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(4) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(5) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(6) li:nth-of-type(1) div.col-md-2:nth-of-type(2)", false)

    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", "10.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(4)", false)

  end







end