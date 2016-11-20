require 'test_helper'

class DonationsReportTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @volunteer1 = Volunteer.new(first_name: "Volunteer", last_name: " #1", zip: "53555-9621")
    @volunteer1.save
    @volunteer2 = Volunteer.new(first_name: "Volunteer", last_name: " #2", zip: "53555")
    @volunteer2.save
    @volunteer3 = Volunteer.new(first_name: "Volunteer", last_name: " #3", zip: "53711")
    @volunteer3.save
    @volunteer4 = Volunteer.new(first_name: "Volunteer", last_name: " #4")
    @volunteer4.save
    @organization1 = Organization.new(name: "Organization #1", organization_type_id: 1)
    @organization1.save
    @organization2 = Organization.new(name: "Organization #2", organization_type_id: 1)
    @organization2.save
    @organization3 = Organization.new(name: "Organization #3", organization_type_id: 1)
    @organization3.save
    @donation_type1 = DonationType.new(name: "Cash")
    @donation_type1.save
    @donation_type2 = DonationType.new(name: "Check")
    @donation_type2.save
    @donation_type3 = DonationType.new(name: "PickUp", non_monetary: "TRUE")
    @donation_type3.save

    @donation1 = Donation.new(date_received: 1.days.ago.to_s(:db), value: 10, volunteer: @volunteer1, donation_type: @donation_type1)
    @donation1.save
    @donation2 = Donation.new(date_received: 2.days.ago.to_s(:db), value: 0, item: "Couch", volunteer: @volunteer1, donation_type: @donation_type3)
    @donation2.save
    @donation3 = Donation.new(date_received: 7.days.ago.to_s(:db), value: 20, volunteer: @volunteer1, donation_type: @donation_type2)
    @donation3.save
    @donation4 = Donation.new(date_received: 1.days.ago.to_s(:db), value: 5, volunteer: @volunteer2, donation_type: @donation_type1)
    @donation4.save
    @donation5 = Donation.new(date_received: 1.days.ago.to_s(:db), value: 10, item: "Chair", volunteer: @volunteer2, donation_type: @donation_type3)
    @donation5.save
    @donation6 = Donation.new(date_received: 6.days.ago.to_s(:db), value: 7, volunteer: @volunteer3, donation_type: @donation_type1)
    @donation6.save
    @donation7 = Donation.new(date_received: 5.days.ago.to_s(:db), value: 30, volunteer: @volunteer4, donation_type: @donation_type2)
    @donation7.save
    @donation8 = Donation.new(date_received: 4.days.ago.to_s(:db), value: 500, organization: @organization1, donation_type: @donation_type1)
    @donation8.save
    @donation9 = Donation.new(date_received: 1.days.ago.to_s(:db), value: 100, organization: @organization2, donation_type: @donation_type2)
    @donation9.save
    @donation10 = Donation.new(date_received: 7.days.ago.to_s(:db), value: 0, items: "Desks", organization: @organization3, donation_type: @donation_type3)
    @donation10.save



  end

  def teardown
    @donation1.destroy
    @donation2.destroy
    @donation3.destroy
    @donation4.destroy
    @donation5.destroy
    @donation6.destroy
    @donation7.destroy
    @donation8.destroy
    @donation9.destroy
    @donation10.destroy

    @volunteer1.destroy
    @volunteer2.destroy
    @volunteer3.destroy
    @volunteer4.destroy
    @organization1.destroy
    @organization2.destroy
    @organization3.destroy
    @donation_type1.destroy
    @donation_type2.destroy
    @donation_type3.destroy


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
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "2")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "3.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "1")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "2")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "15.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "0")

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

    assert_select("div.container h4:nth-of-type(1)", "Project: Build #1")
    assert_select("div.container h5:nth-of-type(1)", "Distinct Project Volunteers: 2, Volunteer Shifts: 4, Volunteer Hours: 18.0")
    assert_select("div.container h5:nth-of-type(2)", "Distinct Project Organizations: 1, Organization Hours: 56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "17.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "1.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "56.0")

    assert_select("div.container h4:nth-of-type(2)", "Project: Build #2")
    assert_select("div.container h5:nth-of-type(3)", "Distinct Project Volunteers: 1, Volunteer Shifts: 1, Volunteer Hours: 12.0")
    assert_select("div.container h5:nth-of-type(4)", "Distinct Project Organizations: 1, Organization Hours: 10.0")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "12.0")
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "10.0")

    assert_select("div.container h4:nth-of-type(3)", "Project: Build #4")
    assert_select("div.container h5:nth-of-type(5)", "Distinct Project Volunteers: 2, Volunteer Shifts: 2, Volunteer Hours: 5.0")
    assert_select("div.container ul.listing:nth-of-type(5) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "3.0")
    assert_select("div.container ul.listing:nth-of-type(5) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "2.0")

    assert_select("div.container h4:nth-of-type(4)", "Project: Build #3")
    assert_select("div.container h5:nth-of-type(6)", "Distinct Project Organizations: 1, Organization Hours: 6.0")
    assert_select("div.container ul.listing:nth-of-type(6) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "6.0")

    assert_select("div.container h4:nth-of-type(6)", "Distinct Volunteers: 4 Volunteer Shifts: 7 Volunteer Hours: 35.0")
    assert_select("div.container h4:nth-of-type(7)", "Distinct Organizations: 3 Organization Hours: 72.0")

  end

  test "Hours by Participant HTML Report" do
    log_in_as(@user)
    get report_workdays_path(report_type: 3, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")

    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "19.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "12.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "3.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(4) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "1.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(5) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(6) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)

    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "10.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "6.0")

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
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "17.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "1.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "56.0")

    assert_select("div.container h4:nth-of-type(2)", "Project: Build #2")
    assert_select("div.container h5:nth-of-type(3)", "Distinct Project Volunteers: 1, Volunteer Shifts: 1, Volunteer Hours: 12.0")
    assert_select("div.container h5:nth-of-type(4)", "Distinct Project Organizations: 1, Organization Hours: 10.0")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "12.0")
    assert_select("div.container ul.listing:nth-of-type(4) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "10.0")

    assert_select("div.container h4:nth-of-type(4)", "Distinct Volunteers: 3 Volunteer Shifts: 5 Volunteer Hours: 30.0")
    assert_select("div.container h4:nth-of-type(5)", "Distinct Organizations: 2 Organization Hours: 66.0")

  end

  test "Hours by Participant HTML Report, filter on project" do
    log_in_as(@user)
    get report_workdays_path(report_type: 3, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "", project_ids: [@project1.id, @project2.id])

    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "17.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "12.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "1.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(4) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(5) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(6) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)

    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "10.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", false)

  end

  test "Workdays by Project HTML Report, filter on volunteer category and project" do
    log_in_as(@user)
    @volunteer1.volunteer_categories = [@volunteer_category]
    @volunteer1.save
    get report_workdays_path(report_type: 1, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "", volunteer_category_ids: [@volunteer_category.id], project_ids: [@project1.id, @project2.id])

    assert_select("div.container h4:nth-of-type(1)", "Project: Build #1")
    assert_select("div.container h5:nth-of-type(1)", "Distinct Project Volunteers: 1, Volunteer Shifts: 3, Volunteer Hours: 17.0")
    assert_select("div.container h5:nth-of-type(2)", "Distinct Project Organizations: 1, Organization Hours: 56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "1")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "2.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "1")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(1)", "2")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(2)", "15.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(3)", "0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "0")

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
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "17.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "56.0")

    assert_select("div.container h4:nth-of-type(2)", "Project: Build #2")
    assert_select("div.container h5:nth-of-type(3)", "Distinct Project Organizations: 1, Organization Hours: 10.0")
    assert_select("div.container ul.listing:nth-of-type(3) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "10.0")

    assert_select("div.container h4:nth-of-type(4)", "Distinct Volunteers: 1 Volunteer Shifts: 3 Volunteer Hours: 17.0")
    assert_select("div.container h4:nth-of-type(5)", "Distinct Organizations: 2 Organization Hours: 66.0")

  end

  test "Hours by Participant HTML Report, filter on volunteer category and project" do
    log_in_as(@user)
    @volunteer1.volunteer_categories = [@volunteer_category]
    @volunteer1.save
    get report_workdays_path(report_type: 3, report_format: 1, from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "", volunteer_category_ids: [@volunteer_category.id], project_ids: [@project1.id, @project2.id])

    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", "17.0")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(4) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(5) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(6) li:nth-of-type(1) div.col-md-2:nth-of-type(3)", false)

    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "56.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", "10.0")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-2:nth-of-type(5)", false)

  end







end