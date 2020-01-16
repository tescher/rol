require 'test_helper'
require 'pp'


class VolunteersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @volunteer = volunteers(:one)
    @volunteer2 = volunteers(:volunteer_2)
    @duplicate_volunteer = volunteers(:duplicate)
    @minor_volunteer = volunteers(:minor)
    @guardian_volunteer = volunteers(:guardian)
    @admin = users(:michael)
    @non_admin = users(:one)
    @monetary_donation_user = users(:monetary_donation)
    @non_monetary_donation_user = users(:non_monetary_donation)
    @contact_method = contact_methods(:one)
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
      5.times do |n|
        waiver = Waiver.new
        waiver.volunteer_id = v.id
        waiver.adult = true
        waiver.birthdate = DateTime.parse("2000-02-01")
        waiver.data = "Some text for waiver #{n}."
        waiver.date_signed = (n+10).day.ago.to_s(:db)
        waiver.save
      end
      5.times do |n|
        contact = Contact.new
        contact.volunteer_id = v.id
        contact.notes = "Some notes"
        contact.contact_method_id = @contact_method.id
        contact.user_id = @non_admin.id
        contact.date_time = DateTime.parse("2018-06-01 10:00:00")
        contact.save
      end
      WaiverText.create(waiver_type: WaiverText.waiver_types[:adult], bypass_file: true, data: "Adult master text", created_at: DateTime.parse("2018-07-01"))
      WaiverText.create(waiver_type: WaiverText.waiver_types[:minor], bypass_file: true, data: "Minor master text", created_at: DateTime.parse("2018-07-01"))
      WorkdayVolunteer.create(workday: workdays(:one), volunteer: v, hours: 4)
      interest1 = interests(:one)
      interest2 = interests(:two)
      interest3 = interests(:three)
      category1 = volunteer_categories(:intern)
      category2 = volunteer_categories(:huber)
      category3 = volunteer_categories(:master)
      if (v == @volunteer)
        volunteer_interest = VolunteerInterest.new
        volunteer_interest.volunteer = v
        volunteer_interest.interest = interest1
        volunteer_interest.save
        volunteer_interest = VolunteerInterest.new
        volunteer_interest.volunteer = v
        volunteer_interest.interest = interest2
        volunteer_interest.save
        volunteer_category_volunteer = VolunteerCategoryVolunteer.new
        volunteer_category_volunteer.volunteer = v
        volunteer_category_volunteer.volunteer_category = category1
        volunteer_category_volunteer.save
        volunteer_category_volunteer = VolunteerCategoryVolunteer.new
        volunteer_category_volunteer.volunteer = v
        volunteer_category_volunteer.volunteer_category = category2
        volunteer_category_volunteer.save
        Waiver.create(volunteer_id: v.id, date_signed: DateTime.parse("2010-06-01"), e_sign:true, adult: false, guardian_id: @volunteer2.id)
      else
        volunteer_interest = VolunteerInterest.new
        volunteer_interest.volunteer = v
        volunteer_interest.interest = interest2
        volunteer_interest.save
        volunteer_interest = VolunteerInterest.new
        volunteer_interest.volunteer = v
        volunteer_interest.interest = interest3
        volunteer_interest.save
        volunteer_category_volunteer = VolunteerCategoryVolunteer.new
        volunteer_category_volunteer.volunteer = v
        volunteer_category_volunteer.volunteer_category = category2
        volunteer_category_volunteer.save
        volunteer_category_volunteer = VolunteerCategoryVolunteer.new
        volunteer_category_volunteer.volunteer = v
        volunteer_category_volunteer.volunteer_category = category3
        volunteer_category_volunteer.save
        Waiver.create(volunteer_id: v.id, date_signed: DateTime.parse("2010-06-01"), e_sign:true, adult: true)
        Waiver.create(volunteer_id: @minor_volunteer.id, guardian_id: v.id, e_sign: true, date_signed: DateTime.parse("2010-06-01"))
        # Create a weird situation where a person is both volunteer and guardian on a waiver. This waiver should essentially be "merged" into one target waiver
        Waiver.create(volunteer_id: @volunteer.id, guardian_id: v.id, e_sign: true, date_signed: DateTime.parse("2010-06-01"))
      end
    end
  end

  def teardown
    [@volunteer, @volunteer2, @duplicate_volunteer, @minor_volunteer, @guardian_volunteer].each do |v|
      Donation.where("volunteer_id = #{v.id}") do |d|
        d.destroy
      end
      WorkdayVolunteer.where("volunteer_id = #{v.id}") do |w|
        w.destroy
      end
      VolunteerInterest.where("volunteer_id = #{v.id}") do |i|
        i.destroy
      end
      VolunteerCategoryVolunteer.where("volunteer_id = #{v.id}") do |i|
        i.destroy
      end
      Waiver.where("volunteer_id = #{v.id}") do |i|
        i.really_destroy!
      end
      Waiver.where("guardian_id = #{v.id}") do |i|
        i.really_destroy!
      end
      Contact.where("volunteer_id = #{v.id}") do |c|
        c.destroy
      end

      if v.persisted?
        v.really_destroy!
      end
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

  test "List waivers" do
    log_in_as(@non_admin)
    get waivers_volunteer_path(@volunteer)
    assert_template "waivers/waivers_form"
    waivers = Waiver.where("volunteer_id = '#{@volunteer.id}'")
    waivers.each do |waiver|
      assert_select "input[value='#{waiver.id}']"
    end
  end

  test "List contacts" do
    log_in_as(@admin)
    get contacts_volunteer_path(@volunteer)
    assert_template "contacts/contacts_form"
    contacts = Contact.where("volunteer_id = '#{@volunteer.id}'")
    contacts.each do |contact|
      assert_select "input[value='#{contact.id}']"
    end
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_volunteer_path(@volunteer)
    assert_template 'volunteers/edit'
    patch volunteer_path(@volunteer), params: { volunteer: { first_name:  "",
                                                   email: "foo@invalid" } }
    assert_template 'volunteers/edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_volunteer_path(@volunteer)
    assert_template 'volunteers/edit'
    first_name  = "Foo"
    last_name = "Bar"
    email = "foo@bar.com"
    patch volunteer_path(@volunteer), params: { volunteer: { first_name:  first_name,
                                                   last_name: last_name,
                                                   email: email } }
    # assert_not flash.empty?
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
    patch volunteer_path(@volunteer), params: { volunteer: { first_name:  first_name,
                                                   last_name: last_name,
                                                   email: email } }
    assert_not flash.empty?
    assert_redirected_to search_volunteers_url
    @volunteer.reload
    assert_equal @volunteer.first_name,  first_name
    assert_equal @volunteer.last_name,  last_name
    assert_equal @volunteer.email, email
  end

  test "Find family donation with funky address" do
    funky_address = "D'Nure St & 5th @ Vine"
    funky_city = "L'odi"
    @volunteer1 = volunteers(:volunteer_1)
    @volunteer1.address = funky_address
    @volunteer1.city = funky_city
    @volunteer1.save
    log_in_as(@monetary_donation_user)
    get edit_volunteer_path(@volunteer1)
    assert_template 'volunteers/edit'
    assert_select 'a[id="linkDonationSummaryMonetary"]', false
    @volunteer.address = funky_address
    @volunteer.city = funky_city
    @volunteer.save
    get edit_volunteer_path(@volunteer1)
    assert_template 'volunteers/edit'
    assert_select 'a[id="linkDonationSummaryMonetary"]', true
  end

  test "successful delete as admin" do
    log_in_as(@admin)
    get edit_volunteer_path(@volunteer)
    assert_select 'a[href=?]', volunteer_path(@volunteer), method: :delete
    before_wdv = WorkdayVolunteer.count
    wdv_to_delete = WorkdayVolunteer.where("volunteer_id = #{@volunteer.id}").count
    before_v = Volunteer.count
    before_d = Donation.count
    d_to_delete = Donation.where("volunteer_id = #{@volunteer.id}").count
    before_wd = Workday.count
    before_c = VolunteerCategoryVolunteer.count
    c_to_delete = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").count
    before_wv = Waiver.count
    wv_to_delete = Waiver.where("volunteer_id = #{@volunteer.id}").count
    before_ct = Contact.count
    ct_to_delete = Contact.where("volunteer_id = #{@volunteer.id}").count
    delete volunteer_path(@volunteer)
    after_wdv = WorkdayVolunteer.count
    after_v = Volunteer.count
    after_d = Donation.count
    after_wd = Workday.count
    after_c = VolunteerCategoryVolunteer.count
    after_wv = Waiver.count
    after_ct = Contact.count
    # Make sure all cascade deletes worked OK
    assert_equal before_v - 1, after_v
    assert_equal before_d - d_to_delete, after_d
    assert_equal before_wd, after_wd
    assert_equal before_wdv - wdv_to_delete, after_wdv
    assert_equal before_c - c_to_delete, after_c
    assert_equal before_wv - wv_to_delete, after_wv
    assert_equal before_ct - ct_to_delete, after_ct

    @volunteer.reload
    assert(@volunteer.deleted?)
  end

  test "No delete if not admin" do
    log_in_as(@user)
    get edit_volunteer_path(@volunteer)
    assert_select "a[href='#{volunteer_path(@volunteer)}'][data-method=delete]", false, "Should not have a delete link"
  end

  test "New volunteer from pending volunteer" do
    log_in_as(@user)
    @pending_volunteer = volunteers(:pending_one)
    get new_volunteer_path(pending_volunteer_id: @pending_volunteer)
    assert_template 'new'
    assert_select "[name*=first_name]" do
      assert_select "[value=?]", @pending_volunteer.first_name
    end
    @volunteer = Volunteer.new()
    post volunteers_path(@volunteer), params: { volunteer: {
        first_name: @pending_volunteer.first_name,
        last_name: @pending_volunteer.last_name, pending_volunteer_id: @pending_volunteer.id }
    }
    updated_volunteer = Volunteer.find(@pending_volunteer.id)
    # Original record was convereted to ensure that this is the case.
    assert_equal(updated_volunteer.first_name, @pending_volunteer.first_name)
    assert_equal(updated_volunteer.last_name, @pending_volunteer.last_name)
    assert_equal(updated_volunteer.needs_review, false)
    assert_nil(updated_volunteer.deleted_at)
  end


  test "Merge duplicate into volunteer" do  # Duplicate is the source, volunteer is the target
    log_in_as(@non_admin)
    workdays = WorkdayVolunteer.where("volunteer_id = #{@volunteer.id}").all
    workdays_count = workdays.count # Need to do here to make sure query runs before merge
    workdays_dup = WorkdayVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").all
    workdays_dup_count = workdays_dup.count
    volunteer_interests = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all
    volunteer_interests_count = volunteer_interests.count
    donations = Donation.where("volunteer_id = #{@volunteer.id}").all
    donations_count = donations.count
    donations_dup = Donation.where("volunteer_id = #{@duplicate_volunteer.id}").all
    donations_dup_count = donations_dup.count
    waivers = Waiver.where("(volunteer_id = #{@volunteer.id}) OR (guardian_id = #{@volunteer.id})").distinct.all
    waivers_count = waivers.count
    waivers_dup = Waiver.where("(volunteer_id = #{@duplicate_volunteer.id}) OR (guardian_id = #{@duplicate_volunteer.id})").distinct.all
    waivers_dup_count = waivers_dup.count
    contacts = Contact.where("(volunteer_id = #{@volunteer.id})").all
    contacts_count = contacts.count
    contacts_dup = Contact.where("(volunteer_id = #{@duplicate_volunteer.id})").all
    contacts_dup_count = contacts_dup.count
    notes = @volunteer.notes
    volunteer_category_volunteers = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all
    volunteer_category_volunteers_count = volunteer_category_volunteers.count

    source_use_field_list = [:first_name, :last_name, :waiver_date, :remove_from_mailing_list, :agree_to_background_check, :primary_employer_contact, :church_id, :home_phone, :adult, :birthdate]
    source_use_fields = source_use_field_list.map {|f,i| Volunteer.merge_fields_table[f] }

    use_notes = "ignore"   # Skip notes and interests and categories on this first pass
    use_limitations = "ignore"
    use_medical_conditions = "ignore"
    use_interests = "ignore"
    use_categories = "ignore"

    post merge_volunteer_path(@volunteer), params: { source_id: @duplicate_volunteer.id, source_use_fields: source_use_fields, use_notes: use_notes, use_limitations: use_limitations, use_medical_conditions: use_medical_conditions, use_interests: use_interests, use_categories: use_categories }

    @volunteer.reload

    # Did all fields merge as expected?
    Volunteer.merge_fields_table.each do |field,index|
      if source_use_field_list.include? field
        if @duplicate_volunteer[field].nil?
          assert_nil @volunteer[field], "Field #{field.to_s} should be equal"
        else
          assert_equal(@volunteer[field], @duplicate_volunteer[field],"Field #{field.to_s} should be equal")
        end
      else
        assert_not_equal(@volunteer[field], @duplicate_volunteer[field],"Field #{field.to_s} should not be equal")
      end
    end

    # Did workdays move?
    assert_equal(WorkdayVolunteer.where("volunteer_id = #{@volunteer.id}").all.count, workdays_count + workdays_dup_count, "Number of workdays (#{workdays_count + workdays_dup_count}) should be equal")

    # Did donations move and is the amount the same?
    new_donations = Donation.where("volunteer_id = #{@volunteer.id}").all
    assert_equal(new_donations.count, donations_count + donations_dup_count, "Number of donations (#{donations_count + donations_dup_count}) should be equal")
    # puts new_donations.count
    new_total = 0
    old_total = 0
    new_donations.each {|d| new_total += d.value unless d.value.blank? }
    donations.each {|d| old_total += d.value unless d.value.blank? }
    donations_dup.each {|d| old_total += d.value unless d.value.blank? }
    assert_equal(new_total, old_total, "Donation total #{new_total} should be equal")
    # puts new_total,old_total

    # Did waivers move and is the amount the same? Also check for edge case where volunteer was both volunteer and guardian on waiver after merge
    new_waivers = Waiver.where("(volunteer_id = #{@volunteer.id}) OR (guardian_id = #{@volunteer.id})").distinct.all
    assert_equal(waivers_count + waivers_dup_count - 1, new_waivers.count, "Number of waivers (#{waivers_count + waivers_dup_count - 1}) should be equal")
    merged_waivers = Waiver.where("(volunteer_id = #{@volunteer.id}) AND (guardian_id = #{@volunteer.id})").distinct.all
    assert_equal(1, merged_waivers.count, "Number of merged waivers (#{1}) should be equal")

    # Did contacts move and is the amount the same?
    new_contacts = Contact.where("(volunteer_id = #{@volunteer.id})").all
    assert_equal(new_contacts.count, contacts_count + contacts_dup_count, "Number of contacts (#{contacts_count + contacts_dup_count}) should be equal")

    # We had "ignore" for notes and interests and categories, make sure they stayed as is
    assert_equal(@volunteer.notes, notes, "Notes '#{notes}' should have remained as is")
    assert(volunteer_interests.distinct.sort == VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all.distinct.sort, "Interests (#{volunteer_interests_count}) should have remained the same")
    assert(volunteer_category_volunteers.distinct.sort == VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all.distinct.sort, "Categories (#{volunteer_category_volunteers_count}) should have remained the same")

    # Did everything delete OK?
    @duplicate_volunteer.reload
    assert(@duplicate_volunteer.deleted?, "Source volunteer soft deleted");
    assert_equal("Merged with #{@volunteer.id}", @duplicate_volunteer.deleted_reason)
    assert_equal(WorkdayVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").count, 0, "All workday shifts from source gone")
    assert_equal(Donation.where("volunteer_id = #{@duplicate_volunteer.id}").count, 0, "All donations from source gone")
    assert_equal(Waiver.where("volunteer_id = #{@duplicate_volunteer.id}").count, 0, "All waivers from source gone")
    assert_equal(Waiver.where("guardian_id = #{@duplicate_volunteer.id}").count, 0, "All guardian waivers from source gone")
    assert_equal(Contact.where("volunteer_id = #{@duplicate_volunteer.id}").count, 0, "All contacts from source gone")
    assert_equal(VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").count, 0, "All interests from source gone")
    assert_equal(VolunteerCategoryVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").count, 0, "All categories from source gone")

  end

  test "Merge with combined interests and categories" do
    log_in_as(@non_admin)
    volunteer_interests = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all
    volunteer_interests_content = volunteer_interests.map {|v| v.interest_id}
    volunteer_interests_dup = VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_interests_dup_content = volunteer_interests_dup.map {|v| v.interest_id}
    volunteer_category_volunteers = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all
    volunteer_category_volunteers_content = volunteer_category_volunteers.map {|v| v.volunteer_category_id}
    volunteer_category_volunteers_dup = VolunteerCategoryVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_category_volunteers_dup_content = volunteer_category_volunteers_dup.map {|v| v.volunteer_category_id}

    use_notes = "ignore"
    use_limitations = "ignore"
    use_medical_conditions = "ignore"
    use_interests = "add"
    use_categories = "add"

    post merge_volunteer_path(@volunteer), params: { source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_limitations: use_limitations, use_medical_conditions: use_medical_conditions, use_interests: use_interests, use_categories: use_categories }

    @volunteer.reload

    # Did interests move?
    new_volunteer_interests_content = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all.map {|v| v.interest_id}
    assert(new_volunteer_interests_content.sort == (volunteer_interests_content + volunteer_interests_dup_content).uniq.sort, "Interests (#{new_volunteer_interests_content.count}) should be equal")
    # Did categories move?
    new_volunteer_category_volunteers_content = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all.map {|v| v.volunteer_category_id}
    assert(new_volunteer_category_volunteers_content.sort == (volunteer_category_volunteers_content + volunteer_category_volunteers_dup_content).uniq.sort, "Categories (#{new_volunteer_category_volunteers_content.count}) should be equal")
  end

  test "Merge with combined interests and categories, none on source" do
    log_in_as(@non_admin)
    volunteer_interests = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all
    # volunteer_interests_count = volunteer_interests.count
    volunteer_interests_content = volunteer_interests.map {|v| v.interest_id}
    volunteer_interests_dup = VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_interests_dup.each {|i| i.destroy!}
    volunteer_interests_dup = VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").all
    # volunteer_interests_dup_count = volunteer_interests_dup.count
    volunteer_interests_dup_content = volunteer_interests_dup.map {|v| v.interest_id}

    volunteer_category_volunteers = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all
    volunteer_category_volunteers_content = volunteer_category_volunteers.map {|v| v.volunteer_category_id}
    volunteer_category_volunteers_dup = VolunteerCategoryVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_category_volunteers_dup.each {|i| i.destroy!}
    volunteer_category_volunteers_dup = VolunteerCategoryVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_category_volunteers_dup_content = volunteer_category_volunteers_dup.map {|v| v.volunteer_category_id}

    use_notes = "ignore"
    use_limitations = "ignore"
    use_medical_conditions = "ignore"
    use_interests = "add"
    use_categories = "add"

    post merge_volunteer_path(@volunteer), params: { source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_limitations: use_limitations, use_medical_conditions: use_medical_conditions, use_interests: use_interests, use_categories: use_categories }

    @volunteer.reload

    # Did interests move?
    new_volunteer_interests_content = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all.map {|v| v.interest_id}
    assert(new_volunteer_interests_content.sort == (volunteer_interests_content + volunteer_interests_dup_content).uniq.sort, "Interests (#{new_volunteer_interests_content.count}) should be equal")
    # Did categories move?
    new_volunteer_category_volunteers_content = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all.map {|v| v.volunteer_category_id}
    assert(new_volunteer_category_volunteers_content.sort == (volunteer_category_volunteers_content + volunteer_category_volunteers_dup_content).uniq.sort, "Categories (#{new_volunteer_category_volunteers_content.count}) should be equal")
  end


  test "Merge with replaced interests and categories" do
    log_in_as(@non_admin)
    volunteer_interests = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all
    # volunteer_interests_count = volunteer_interests.count
    volunteer_interests_dup = VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_interests_dup.each {|i| i.destroy!}
    volunteer_interests_dup = VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_interests_dup_count = volunteer_interests_dup.count
    volunteer_interests_dup_content = volunteer_interests_dup.map {|v| v.interest_id}

    volunteer_category_volunteers = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all
    volunteer_category_volunteers_dup = VolunteerCategoryVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_category_volunteers_dup.each {|i| i.destroy!}
    volunteer_category_volunteers_dup = VolunteerCategoryVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_category_volunteers_dup_count = volunteer_category_volunteers_dup.count
    volunteer_category_volunteers_dup_content = volunteer_category_volunteers_dup.map {|v| v.volunteer_category_id}

    use_notes = "ignore"
    use_limitations = "ignore"
    use_medical_conditions = "ignore"
    use_interests = "replace"
    use_categories = "replace"

    post merge_volunteer_path(@volunteer), params: { source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_limitations: use_limitations, use_medical_conditions: use_medical_conditions, use_interests: use_interests, use_categories: use_categories }

    @volunteer.reload

    # Did interests move?
    new_volunteer_interests_content = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all.map {|v| v.interest_id}
    assert(new_volunteer_interests_content.sort == volunteer_interests_dup_content.sort, "Interests (#{volunteer_interests_dup_count}) should be equal")
    # Did categories move?
    new_volunteer_category_volunteers_content = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all.map {|v| v.volunteer_category_id}
    assert(new_volunteer_category_volunteers_content.sort == volunteer_category_volunteers_dup_content.sort, "Categories (#{volunteer_category_volunteers_dup_count}) should be equal")
  end

  test "Merge with replaced interests and categories, none on source" do
    log_in_as(@non_admin)
    volunteer_interests = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all
    # volunteer_interests_count = volunteer_interests.count
    volunteer_interests_dup = VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_interests_dup_count = volunteer_interests_dup.count
    volunteer_interests_dup_content = volunteer_interests_dup.map {|v| v.interest_id}

    volunteer_category_volunteers = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all
    volunteer_category_volunteers_dup = VolunteerCategoryVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_category_volunteers_dup_count = volunteer_category_volunteers_dup.count
    volunteer_category_volunteers_dup_content = volunteer_category_volunteers_dup.map {|v| v.volunteer_category_id}

    use_notes = "ignore"
    use_limitations = "ignore"
    use_medical_conditions = "ignore"
    use_interests = "replace"
    use_categories = "replace"

    post merge_volunteer_path(@volunteer), params: { source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_limitations: use_limitations, use_medical_conditions: use_medical_conditions, use_interests: use_interests, use_categories: use_categories }

    @volunteer.reload

    # Did interests move?
    new_volunteer_interests_content = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all.map {|v| v.interest_id}
    assert(new_volunteer_interests_content.sort == volunteer_interests_dup_content.sort, "Interests (#{volunteer_interests_dup_count}) should be equal")
    # Did categories move?
    new_volunteer_category_volunteers_content = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all.map {|v| v.volunteer_category_id}
    assert(new_volunteer_category_volunteers_content.sort == volunteer_category_volunteers_dup_content.sort, "Categories (#{volunteer_category_volunteers_dup_count}) should be equal")
  end

  test "Merge with appended notes, conditions, limitations" do
    log_in_as(@non_admin)
    notes = @volunteer.notes
    notes_dup = @duplicate_volunteer.notes
    medical_conditions = @volunteer.medical_conditions
    medical_conditions_dup = @duplicate_volunteer.medical_conditions
    limitations = @volunteer.limitations
    limitations_dup = @duplicate_volunteer.limitations

    use_notes = "append"
    use_limitations = "append"
    use_medical_conditions = "append"
    use_interests = "ignore"
    use_categories = "ignore"

    post merge_volunteer_path(@volunteer), params: { source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_limitations: use_limitations, use_medical_conditions: use_medical_conditions, use_interests: use_interests, use_categories: use_categories }

    @volunteer.reload

    # Did notes move?
    assert_equal(@volunteer.notes, notes + "\n" + notes_dup, "Notes (#{notes + "\n" + notes_dup}) should be equal")
    assert_equal(@volunteer.limitations, limitations + "\n" + limitations_dup, "Limitations (#{limitations + "\n" + limitations_dup}) should be equal")
    assert_equal(@volunteer.medical_conditions, medical_conditions + "\n" + medical_conditions_dup, "Medical conditions (#{medical_conditions + "\n" + medical_conditions_dup}) should be equal")
  end

  test "Merge with prepended notes, conditions, limitations" do
    log_in_as(@non_admin)
    notes = @volunteer.notes
    notes_dup = @duplicate_volunteer.notes
    medical_conditions = @volunteer.medical_conditions
    medical_conditions_dup = @duplicate_volunteer.medical_conditions
    limitations = @volunteer.limitations
    limitations_dup = @duplicate_volunteer.limitations

    use_notes = "prepend"
    use_limitations = "prepend"
    use_medical_conditions = "prepend"
    use_interests = "ignore"
    use_categories = "ignore"

    post merge_volunteer_path(@volunteer), params: { source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_limitations: use_limitations, use_medical_conditions: use_medical_conditions, use_interests: use_interests, use_categories: use_categories }

    @volunteer.reload

    # Did notes move?
    assert_equal(@volunteer.notes, notes_dup + "\n" + notes, "Notes (#{notes_dup + "\n" + notes}) should be equal")
    assert_equal(@volunteer.limitations, limitations_dup + "\n" + limitations, "Limitations (#{limitations_dup + "\n" + limitations}) should be equal")
    assert_equal(@volunteer.medical_conditions, medical_conditions_dup + "\n" + medical_conditions, "Medical conditions (#{medical_conditions_dup + "\n" + medical_conditions}) should be equal")
  end

  test "Merge with replaced notes, conditions, limitations" do
    log_in_as(@non_admin)
    notes = @volunteer.notes
    notes_dup = @duplicate_volunteer.notes
    medical_conditions = @volunteer.medical_conditions
    medical_conditions_dup = @duplicate_volunteer.medical_conditions
    limitations = @volunteer.limitations
    limitations_dup = @duplicate_volunteer.limitations

    use_notes = "replace"
    use_limitations = "replace"
    use_medical_conditions = "replace"
    use_interests = "ignore"
    use_categories = "ignore"

    post merge_volunteer_path(@volunteer), params: { source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_limitations: use_limitations, use_medical_conditions: use_medical_conditions, use_interests: use_interests, use_categories: use_categories }

    @volunteer.reload

    # Did notes stay?
    assert_equal(@volunteer.notes, notes_dup, "Notes (#{notes_dup}) should be equal")
    assert_equal(@volunteer.limitations, limitations_dup, "Limitations (#{limitations_dup}) should be equal")
    assert_equal(@volunteer.medical_conditions, medical_conditions_dup, "Medical conditions (#{medical_conditions_dup}) should be equal")
  end

  test "no delete if a guardian on a waiver" do
    log_in_as(@admin)
    @waiver = Waiver.new(volunteer_id: @minor_volunteer.id, adult: false, guardian_id: @guardian_volunteer.id, date_signed: DateTime.parse("2018-06-01"))
    @waiver.save!
    # puts @waiver.reload.to_yaml
    get edit_volunteer_path(@guardian_volunteer)
    assert_select 'a[href=?]', volunteer_path(@guardian_volunteer), method: :delete
    assert_no_difference 'Volunteer.count' do
      delete volunteer_path(@guardian_volunteer)
    end
    @waiver.guardian_id = nil
    @waiver.adult = true
    @waiver.save!
    assert_difference 'Volunteer.count', -1 do
      delete volunteer_path(@guardian_volunteer)
    end

  end

  test "Get correct waiver text if text is on waiver" do
    log_in_as(@admin)
    # puts "Get correct waiver text if text is on waiver"
    assert_match /Some text for waiver/, effective_waiver_text(last_waiver(@volunteer.id)).data, "Waiver text should match volunteer waivers"
    @waiver = Waiver.new(volunteer_id: @volunteer.id, e_sign: true, adult: true, date_signed: Date.today, created_at: DateTime.parse("2018-07-01") )
    @waiver.save!
    assert_match /Adult master text/, effective_waiver_text(last_waiver(@volunteer.id)).data, "Waiver text should match adult master waiver"
    @waiver.adult=false
    @waiver.guardian_id = @guardian_volunteer.id
    @waiver.save!
    assert_match /Minor master text/, effective_waiver_text(last_waiver(@volunteer.id)).data, "Waiver text should match minor master waiver"

  end

end
