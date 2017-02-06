require 'test_helper'

class OrganizationsEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @organization = organizations(:one)
    @admin = users(:michael)
    @non_admin = users(:one)
    @monetary_donation_user = users(:monetary_donation)
    @non_monetary_donation_user = users(:non_monetary_donation)
    5.times do |n|
      @donation = Donation.new
      @donation.donation_type = donation_types(:cash)
      @donation.organization = @organization
      @donation.value = 10.00
      @donation.date_received = n.day.ago.to_s(:db)
      @donation.save
    end
    5.times do |n|
      @donation = Donation.new
      @donation.donation_type = donation_types(:restore)
      @donation.organization = @organization
      @donation.date_received = n.day.ago.to_s(:db)
      @donation.save
    end
    @workday_organization = WorkdayOrganization.new
    @workday_organization.workday = workdays(:one)
    @workday_organization.organization = @organization
    @workday_organization.hours = 4
    @workday_organization.save
  end

  def teardown
    Donation.all.each do |d|
      d.destroy
    end
    @workday_organization.destroy
  end

  test "No imports by non-admin" do
    log_in_as(@non_admin)
    get import_organizations_path
    assert_redirected_to root_url
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_organization_path(@organization)
    assert_template 'organizations/edit'
    patch organization_path(@organization), organization: { name:  "",
                                                            email: "foo@invalid" }
    assert_template 'organizations/edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_organization_path(@organization)
    assert_template 'organizations/edit'
    name  = "Foo"
    email = "foo@bar.com"
    patch organization_path(@organization), organization: { name:  name,
                                                            email: email }
    assert_not flash.empty?
    assert_redirected_to search_organizations_url
    @organization.reload
    assert_equal @organization.name,  name
    assert_equal @organization.email, email
  end

  test "successful edit with friendly forwarding" do
    get edit_organization_path(@organization)
    log_in_as(@user)
    assert_redirected_to edit_organization_path(@organization)
    name  = "Foo"
    email = "foo@bar.com"
    patch organization_path(@organization), organization: { name:  name,
                                                            email: email }
    assert_not flash.empty?
    assert_redirected_to search_organizations_url
    @organization.reload
    assert_equal @organization.name,  name
    assert_equal @organization.email, email
  end

  test "successful delete as admin" do
    log_in_as(@admin)
    get edit_organization_path(@organization)
    assert_select 'a[href=?]', organization_path(@organization), method: :delete

    before_wdv = WorkdayOrganization.count
    # puts before_wdv
    before_v = Organization.count
    # puts before_v
    before_d = Donation.count
    # puts before_d
    before_wd = Workday.count
    # puts before_wd
    delete organization_path(@organization)
    after_wdv = WorkdayOrganization.count
    # puts after_wdv
    after_v = Organization.count
    # puts after_v
    after_d = Donation.count
    # puts after_d
    after_wd = Workday.count
    # puts after_wd
    # Make sure all cascade deletes worked OK
    assert_equal before_v - 1, after_v
    assert_equal before_d - 10, after_d
    assert_equal before_wd, after_wd
    assert_equal before_wdv - 1, after_wdv

  end

  test "No delete if not admin" do
    log_in_as(@user)
    get edit_organization_path(@organization)
    assert_no_match 'a[href=?]', organization_path(@organization), method: :delete
  end


end
