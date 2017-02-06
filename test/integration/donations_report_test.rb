require 'test_helper'

class DonationsReportTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @volunteer1 = Volunteer.new(first_name: "One", last_name: "Volunteer", zip: "53555-9621", city: "Lodi")
    @volunteer1.save
    @volunteer2 = Volunteer.new(first_name: "Two", last_name: "Volunteer", zip: "53555", city: "lodi")
    @volunteer2.save
    @volunteer3 = Volunteer.new(first_name: "Three", last_name: "Volunteer", zip: "53711", city: "Baraboo")
    @volunteer3.save
    @volunteer4 = Volunteer.new(first_name: "Four", last_name: "Volunteer", zip:"99674")
    @volunteer4.save
    @organization_type2 = OrganizationType.new(name: "OT2")
    @organization_type2.save
    @organization1 = Organization.new(name: "Organization One", organization_type_id: 1, zip: "53711", city: "Lodi")
    @organization1.save
    @organization2 = Organization.new(name: "Organization Two", organization_type: @organization_type2, zip: "535555", city: "Baraboo")
    @organization2.save
    @organization3 = Organization.new(name: "Organization Three", organization_type_id: 1)
    @organization3.save
    @donation_type1 = DonationType.new(name: "DT1", non_monetary: "FALSE")
    @donation_type1.save
    @donation_type2 = DonationType.new(name: "DT2", non_monetary: "FALSE")
    @donation_type2.save
    @donation_type3 = DonationType.new(name: "DT3", non_monetary: "TRUE")
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
    @donation10 = Donation.new(date_received: 7.days.ago.to_s(:db), value: 0, item: "Desks", organization: @organization3, donation_type: @donation_type3)
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

    @volunteer1.really_destroy!
    @volunteer2.really_destroy!
    @volunteer3.really_destroy!
    @volunteer4.really_destroy!
    @organization1.destroy
    @organization2.destroy
    @organization3.destroy
    @donation_type1.destroy
    @donation_type2.destroy
    @donation_type3.destroy
    @organization_type2.destroy


  end


  test "Report without login" do
    get report_donations_path(report_type: 1, volunteers: 1, city: "", zip: "", request_format:"html", from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")
    log_in_as(@user)
    assert_redirected_to report_donations_path(report_type: 1, volunteers: 1, city: "", zip: "", request_format:"html", from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")
  end

  test "Donations, Monetary, Volunteers, last 6 days, HTML" do
    log_in_as(@user)
    get report_donations_path(report_type: 1, volunteers: 1, city: "", zip: "", request_format:"html", from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")

    assert_select("div.container h2:nth-of-type(1)", "Volunteer Donations")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$30.00")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$10.00")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$7.00")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(4) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$5.00")

    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row, span:nth-of-type(1)", "Number of Donations: 4")
    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row, span:nth-of-type(2)", "Volunteer Total: $52.00")

  end

  test "Donations, Non-Monetary, Organizations, last 7 days, HTML" do
    log_in_as(@user)
    get report_donations_path(report_type: 2, organizations: 1, city: "", zip: "", request_format:"html", from_date: 7.days.ago.strftime("%m/%d/%Y"), to_date: "")

    assert_select("div.container h2:nth-of-type(1)", "Organization Donations")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$0.00")

    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row, span:nth-of-type(1)", "Number of Donations: 1")

  end

  test "Donations, Monetary, Volunteers, Zip 53555, last 6 days, HTML" do
    log_in_as(@user)
    get report_donations_path(report_type: 1, volunteers: 1, organizations: 1, city: "", zip: "53555", request_format:"html", from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")

    assert_select("div.container h2:nth-of-type(1)", "Organization Donations")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$100.00")

    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row div.col-md-6 span:nth-of-type(1)", "Number of Donations: 1")
    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row div.col-md-6 span:nth-of-type(2)", "Organization Total: $100.00")

    assert_select("div.container h2:nth-of-type(2)", "Volunteer Donations")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$10.00")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$5.00")

    assert_select("div.container ul.listing:nth-of-type(2) li:nth-of-type(1) div.row div.col-md-6  span:nth-of-type(1)", "Number of Donations: 2")
    assert_select("div.container ul.listing:nth-of-type(2) li:nth-of-type(1) div.row div.col-md-6  span:nth-of-type(2)", "Volunteer Total: $15.00")

  end

  test "Donations, Monetary, Volunteers, Donation Type 2, last 7 days, HTML" do
    log_in_as(@user)
    get report_donations_path(report_type: 1, volunteers: 1, city: "", zip: "", donation_type_ids: [@donation_type2.id], request_format:"html", from_date: 7.days.ago.strftime("%m/%d/%Y"), to_date: "")

    assert_select("div.container h2:nth-of-type(1)", "Volunteer Donations")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$30.00")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$20.00")

    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row span:nth-of-type(1)", "Number of Donations: 2")
    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row span:nth-of-type(2)", "Volunteer Total: $50.00")

  end

  test "Donations, Monetary, Volunteers, Donation Type 1 & 2, last 7 days, HTML" do
    log_in_as(@user)
    get report_donations_path(report_type: 1, volunteers: 1, city: "", zip: "", donation_type_ids: [@donation_type1.id, @donation_type2.id], request_format:"html", from_date: 7.days.ago.strftime("%m/%d/%Y"), to_date: "")

    assert_select("div.container h2:nth-of-type(1)", "Volunteer Donations")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$30.00")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$20.00")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$10.00")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(4) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$7.00")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(5) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$5.00")

    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row, span:nth-of-type(1)", "Number of Donations: 5")
    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row, span:nth-of-type(2)", "Volunteer Total: $72.00")

  end

  test "Donations, Monetary, Organization Type 2, last 7 days, HTML" do
    log_in_as(@user)
    get report_donations_path(report_type: 1, organizations: 1, organization_type_ids: [@organization_type2.id], city: "", zip: "", request_format:"html", from_date: 7.days.ago.strftime("%m/%d/%Y"), to_date: "")

    assert_select("div.container h2:nth-of-type(1)", "Organization Donations")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$100.00")

    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row, span:nth-of-type(1)", "Number of Donations: 1")
    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row, span:nth-of-type(2)", "Organization Total: $100.00")

  end

  test "Donations, Monetary, Volunteers, Zip [53555, 53711], last 6 days, HTML" do
    log_in_as(@user)
    get report_donations_path(report_type: 1, volunteers: 1, organizations: 1, city: "", zip: "53555, 53711", request_format:"html", from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")
    # puts @response.body

    assert_select("div.container h2:nth-of-type(1)", "Organization Donations")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$500.00")

    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row div.col-md-6 span:nth-of-type(1)", "Number of Donations: 2")
    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row div.col-md-6 span:nth-of-type(2)", "Organization Total: $600.00")

    assert_select("div.container h2:nth-of-type(2)", "Volunteer Donations")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$10.00")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$7.00")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$5.00")

    assert_select("div.container ul.listing:nth-of-type(2) li:nth-of-type(1) div.row div.col-md-6  span:nth-of-type(1)", "Number of Donations: 3")
    assert_select("div.container ul.listing:nth-of-type(2) li:nth-of-type(1) div.row div.col-md-6  span:nth-of-type(2)", "Volunteer Total: $22.00")

  end

  test "Donations, Monetary, Volunteers, City [Lodi, Baraboo], last 6 days, HTML" do
    log_in_as(@user)
    get report_donations_path(report_type: 1, volunteers: 1, organizations: 1, city: "lodi, baraboo", zip: "", request_format:"html", from_date: 6.days.ago.strftime("%m/%d/%Y"), to_date: "")
    # puts @response.body

    assert_select("div.container h2:nth-of-type(1)", "Organization Donations")
    assert_select("div.container ul.listing:nth-of-type(1) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$500.00")

    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row div.col-md-6 span:nth-of-type(1)", "Number of Donations: 2")
    assert_select("div.container ul.listing:nth-of-type(1) li:nth-of-type(1) div.row div.col-md-6 span:nth-of-type(2)", "Organization Total: $600.00")

    assert_select("div.container h2:nth-of-type(2)", "Volunteer Donations")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(1) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$10.00")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(2) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$7.00")
    assert_select("div.container ul.listing:nth-of-type(2) div.clickable:nth-of-type(3) li:nth-of-type(1) div.col-md-1:nth-of-type(4)", "$5.00")

    assert_select("div.container ul.listing:nth-of-type(2) li:nth-of-type(1) div.row div.col-md-6  span:nth-of-type(1)", "Number of Donations: 3")
    assert_select("div.container ul.listing:nth-of-type(2) li:nth-of-type(1) div.row div.col-md-6  span:nth-of-type(2)", "Volunteer Total: $22.00")

  end



end
