require 'test_helper'

class VolunteersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @volunteer = volunteers(:one)
    @duplicate_volunteer = volunteers(:duplicate)
    @admin = users(:michael)
    @non_admin = users(:one)
    @monetary_donation_user = users(:monetary_donation)
    @non_monetary_donation_user = users(:non_monetary_donation)
    [@volunteer, @duplicate_volunteer].each do |v|
      5.times do |n|
        donation = Donation.new
        donation.donation_type = donation_types(:cash)
        donation.volunteer_id = v.id
        donation.value = 10.00
        donation.date_received = n.day.ago.to_s(:db)
        donation.save
      end
      5.times do |n|
        donation = Donation.new
        donation.donation_type = donation_types(:restore)
        donation.volunteer_id = v.id
        donation.date_received = n.day.ago.to_s(:db)
        donation.save
      end
      workday_volunteer = WorkdayVolunteer.new
      workday_volunteer.workday = workdays(:one)
      workday_volunteer.volunteer = v
      workday_volunteer.hours = 4
      workday_volunteer.save
      interest1 = interests(:one)
      interest2 = interests(:two)
        volunteer_interest = VolunteerInterest.new
        volunteer_interest.volunteer = v
      if (v == @volunteer)
        volunteer_interest.interest = interest1
      else
        volunteer_interest.interest = interest2
      end
      volunteer_interest.save
    end
  end

  def teardown
    [@volunteer, @duplicate_volunteer].each do |v|
      Donation.where("volunteer_id = #{v.id}") do |d|
        d.destroy
      end
      WorkdayVolunteer.where("volunteer_id = #{v.id}") do |w|
        w.destroy
      end
      VolunteerInterest.where("volunteer_id = #{v.id}") do |i|
        i.destroy
      end
      v.destroy
    end
  end


  test "No imports by non-admin" do
    log_in_as(@non_admin)
    get import_volunteers_path
    assert_redirected_to root_url
  end

  test "Donations by authorized only" do
    log_in_as(@non_admin)
    get donations_volunteer_path(@volunteer)
    assert_redirected_to root_url
  end

  test "All donations by admin or monetary user" do
    [@admin, @monetary_donation_user].each do |user|
      log_in_as(user)
      get donations_volunteer_path(@volunteer)
      assert_template "shared/donations_form"
      donations = Donation.where("volunteer_id = '#{@volunteer.id}'")
      donations.each do |donation|
        assert_select "input[value='#{donation.id}']"
      end
    end
  end

  test "Non-monetary donations by non_monetary user" do
    log_in_as(@non_monetary_donation_user)
    get donations_volunteer_path(@volunteer)
    assert_template "shared/donations_form"
    monetary_donations = Donation.joins(:donation_type).where("volunteer_id = '#{@volunteer.id}' AND NOT donation_types.non_monetary")
    non_monetary_donations = Donation.joins(:donation_type).where("volunteer_id = '#{@volunteer.id}' AND donation_types.non_monetary")
    non_monetary_donations.each do |donation|
      assert_select "input[value='#{donation.id}']"
    end
    monetary_donations.each do |donation|
      assert_select "input[value='#{donation.id}']", false
    end
  end


  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_volunteer_path(@volunteer)
    assert_template 'volunteers/edit'
    patch volunteer_path(@volunteer), volunteer: { first_name:  "",
                                                   email: "foo@invalid" }
    assert_template 'volunteers/edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_volunteer_path(@volunteer)
    assert_template 'volunteers/edit'
    first_name  = "Foo"
    last_name = "Bar"
    email = "foo@bar.com"
    patch volunteer_path(@volunteer), volunteer: { first_name:  first_name,
                                                   last_name: last_name,
                                                   email: email }
    assert_not flash.empty?
    assert_redirected_to search_volunteers_url
    @volunteer.reload
    assert_equal @volunteer.first_name,  first_name
    assert_equal @volunteer.last_name,  last_name
    assert_equal @volunteer.email, email
  end

  test "successful edit with friendly forwarding" do
    get edit_volunteer_path(@volunteer)
    log_in_as(@user)
    assert_redirected_to edit_volunteer_path(@volunteer)
    first_name  = "Foo"
    last_name = "Bar"
    email = "foo@bar.com"
    patch volunteer_path(@volunteer), volunteer: { first_name:  first_name,
                                                   last_name: last_name,
                                                   email: email }
    assert_not flash.empty?
    assert_redirected_to search_volunteers_url
    @volunteer.reload
    assert_equal @volunteer.first_name,  first_name
    assert_equal @volunteer.last_name,  last_name
    assert_equal @volunteer.email, email
  end

  test "successful delete as admin" do
    log_in_as(@admin)
    get edit_volunteer_path(@volunteer)
    assert_select 'a[href=?]', volunteer_path(@volunteer), method: :delete
    before_wdv = WorkdayVolunteer.count
    before_v = Volunteer.count
    before_d = Donation.count
    before_wd = Workday.count
    delete volunteer_path(@volunteer)
    after_wdv = WorkdayVolunteer.count
    after_v = Volunteer.count
    after_d = Donation.count
    after_wd = Workday.count
    # Make sure all cascade deletes worked OK
    assert_equal before_v - 1, after_v
    assert_equal before_d - 10, after_d
    assert_equal before_wd, after_wd
    assert_equal before_wdv - 1, after_wdv
  end

  test "No delete if not admin" do
    log_in_as(@user)
    get edit_volunteer_path(@volunteer)
    assert_no_match 'a[href=?]', volunteer_path(@volunteer), method: :delete
  end

  test "New volunteer from pending volunteer" do
    log_in_as(@user)
    @pending_volunteer = pending_volunteers(:one)
    get new_volunteer_path(pending_volunteer_id: @pending_volunteer)
    assert_template 'new'
    assert_select "[name*=first_name]" do
      assert_select "[value=?]", @pending_volunteer.first_name
    end
    @volunteer = Volunteer.new()
    post volunteers_path(@volunteer), volunteer: {first_name: @pending_volunteer.first_name,
                                                 last_name: @pending_volunteer.last_name, pending_volunteer_id: @pending_volunteer.id}
    @pending_volunteer.reload
    assert_equal(@pending_volunteer.resolved, true)
  end


  test "Merge duplicate into volunteer" do
    log_in_as(@non_admin)
    workdays = WorkdayVolunteer.where("volunteer_id = #{@volunteer.id}").all
    workdays_dup = WorkdayVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_interests = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all
    volunteer_interests_dup = VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").all
    donations = Donations.where("volunteer_id = #{@volunteer.id}").all
    donations_dup = Donations.where("volunteer_id = #{@duplicate_volunteer.id}").all
  end


end