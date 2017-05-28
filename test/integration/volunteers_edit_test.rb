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
	  workday_volunteer = WorkdayVolunteer.create(workday: workdays(:one), volunteer: v, hours: 4)
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
      end
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
      VolunteerCategoryVolunteer.where("volunteer_id = #{v.id}") do |i|
        i.destroy
      end
      v.really_destroy!
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

  test "successful edit with funky address" do
    address_save = @volunteer.address
    @volunteer.address = "D'Nure St & 5th @ Vine"
    @volunteer.save
    log_in_as(@user)
    get edit_volunteer_path(@volunteer)
    assert_template 'volunteers/edit'
    @volunteer.address = volunteer_save
    @volunteer.save
  end

  test "successful delete as admin" do
    log_in_as(@admin)
    get edit_volunteer_path(@volunteer)
    assert_select 'a[href=?]', volunteer_path(@volunteer), method: :delete
    before_wdv = WorkdayVolunteer.count
    before_v = Volunteer.count
    before_d = Donation.count
    before_wd = Workday.count
    before_c = VolunteerCategoryVolunteer.count
    delete volunteer_path(@volunteer)
    after_wdv = WorkdayVolunteer.count
    after_v = Volunteer.count
    after_d = Donation.count
    after_wd = Workday.count
    after_c = VolunteerCategoryVolunteer.count
    # Make sure all cascade deletes worked OK
    assert_equal before_v - 1, after_v
    assert_equal before_d - 10, after_d
    assert_equal before_wd, after_wd
    assert_equal before_wdv - 1, after_wdv
    assert_equal before_c - 2, after_c

    @volunteer.reload
    assert(@volunteer.deleted?)
  end

  test "No delete if not admin" do
    log_in_as(@user)
    get edit_volunteer_path(@volunteer)
    assert_no_match 'a[href=?]', volunteer_path(@volunteer), method: :delete
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
    post volunteers_path(@volunteer), volunteer: {
      first_name: @pending_volunteer.first_name,
      last_name: @pending_volunteer.last_name, pending_volunteer_id: @pending_volunteer.id
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
    volunteer_interests_dup = VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").all
    # volunteer_interests_dup_count = volunteer_interests_dup.count
    donations = Donation.where("volunteer_id = #{@volunteer.id}").all
    donations_count = donations.count
    donations_dup = Donation.where("volunteer_id = #{@duplicate_volunteer.id}").all
    donations_dup_count = donations_dup.count
    notes = @volunteer.notes
    # notes_dup = @duplicate_volunteer.notes
    volunteer_category_volunteers = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all
    volunteer_category_volunteers_count = volunteer_category_volunteers.count

    source_use_field_list = [:first_name, :last_name, :waiver_date, :remove_from_mailing_list, :church_id, :home_phone]
    source_use_fields = source_use_field_list.map {|f,i| Volunteer.merge_fields_table[f] }

    use_notes = "ignore"   # Skip notes and interests and categories on this first pass
    use_interests = "ignore"
    use_categories = "ignore"

    post merge_volunteer_path(@volunteer), {source_id: @duplicate_volunteer.id, source_use_fields: source_use_fields, use_notes: use_notes, use_interests: use_interests, use_categories: use_categories}

    @volunteer.reload

    # Did all fields merge as expected?
    Volunteer.merge_fields_table.each do |field,index|
      if source_use_field_list.include? field
        assert_equal(@volunteer[field], @duplicate_volunteer[field],"Field #{field.to_s} should be equal")
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

    # We had "ignore" for notes and interests and categories, make sure they stayed as is
    assert_equal(@volunteer.notes, notes, "Notes '#{notes}' should have remained as is")
    assert(volunteer_interests.uniq.sort == VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all.uniq.sort, "Interests (#{volunteer_interests_count}) should have remained the same")
    assert(volunteer_category_volunteers.uniq.sort == VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all.uniq.sort, "Categories (#{volunteer_category_volunteers_count}) should have remained the same")

    # Did everything delete OK?
    @duplicate_volunteer.reload
    assert(@duplicate_volunteer.deleted?, "Source volunteer soft deleted");
    assert_equal("Merged with #{@volunteer.id}", @duplicate_volunteer.deleted_reason)
    assert_equal(WorkdayVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").count, 0, "All workday shifts from source gone")
    assert_equal(Donation.where("volunteer_id = #{@duplicate_volunteer.id}").count, 0, "All donations from source gone")
    assert_equal(VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").count, 0, "All interests from source gone")
    assert_equal(VolunteerCategoryVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").count, 0, "All categories from source gone")

  end

  test "Merge with combined interests and categories" do
    log_in_as(@non_admin)
    volunteer_interests = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all
    # volunteer_interests_count = volunteer_interests.count
    volunteer_interests_content = volunteer_interests.map {|v| v.interest_id}
    volunteer_interests_dup = VolunteerInterest.where("volunteer_id = #{@duplicate_volunteer.id}").all
    # volunteer_interests_dup_count = volunteer_interests_dup.count
    volunteer_interests_dup_content = volunteer_interests_dup.map {|v| v.interest_id}
    volunteer_category_volunteers = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all
    volunteer_category_volunteers_content = volunteer_category_volunteers.map {|v| v.volunteer_category_id}
    volunteer_category_volunteers_dup = VolunteerCategoryVolunteer.where("volunteer_id = #{@duplicate_volunteer.id}").all
    volunteer_category_volunteers_dup_content = volunteer_category_volunteers_dup.map {|v| v.volunteer_category_id}

    use_notes = "ignore"
    use_interests = "add"
    use_categories = "add"

    post merge_volunteer_path(@volunteer), {source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_interests: use_interests, use_categories: use_categories}

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
    use_interests = "add"
    use_categories = "add"

    post merge_volunteer_path(@volunteer), {source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_interests: use_interests, use_categories: use_categories}

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
    use_interests = "replace"
    use_categories = "replace"

    post merge_volunteer_path(@volunteer), {source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_interests: use_interests, use_categories: use_categories}

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
    use_interests = "replace"
    use_categories = "replace"

    post merge_volunteer_path(@volunteer), {source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_interests: use_interests, use_categories: use_categories}

    @volunteer.reload

    # Did interests move?
    new_volunteer_interests_content = VolunteerInterest.where("volunteer_id = #{@volunteer.id}").all.map {|v| v.interest_id}
    assert(new_volunteer_interests_content.sort == volunteer_interests_dup_content.sort, "Interests (#{volunteer_interests_dup_count}) should be equal")
    # Did categories move?
    new_volunteer_category_volunteers_content = VolunteerCategoryVolunteer.where("volunteer_id = #{@volunteer.id}").all.map {|v| v.volunteer_category_id}
    assert(new_volunteer_category_volunteers_content.sort == volunteer_category_volunteers_dup_content.sort, "Categories (#{volunteer_category_volunteers_dup_count}) should be equal")
  end

  test "Merge with appended notes" do
    log_in_as(@non_admin)
    notes = @volunteer.notes
    notes_dup = @duplicate_volunteer.notes

    use_notes = "append"
    use_interests = "ignore"
    use_categories = "ignore"

    post merge_volunteer_path(@volunteer), {source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_interests: use_interests, use_categories: use_categories}

    @volunteer.reload

    # Did notes move?
    assert_equal(@volunteer.notes, notes + "\n" + notes_dup, "Notes (#{notes + "\n" + notes_dup}) should be equal")
  end

  test "Merge with prepended notes" do
    log_in_as(@non_admin)
    notes = @volunteer.notes
    notes_dup = @duplicate_volunteer.notes

    use_notes = "prepend"
    use_interests = "ignore"
    use_categories = "ignore"

    post merge_volunteer_path(@volunteer), {source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_interests: use_interests, use_categories: use_categories}

    @volunteer.reload

    # Did notes move?
    assert_equal(@volunteer.notes, notes_dup + "\n" + notes, "Notes (#{notes_dup + "\n" + notes}) should be equal")
  end

  test "Merge with replaced notes" do
    log_in_as(@non_admin)
    notes = @volunteer.notes
    notes_dup = @duplicate_volunteer.notes

    use_notes = "replace"
    use_interests = "ignore"
    use_categories = "ignore"

    post merge_volunteer_path(@volunteer), {source_id: @duplicate_volunteer.id, source_use_fields: [], use_notes: use_notes, use_interests: use_interests, use_categories: use_categories}

    @volunteer.reload

    # Did notes stay?
    assert_equal(@volunteer.notes, notes_dup, "Notes (#{notes_dup}) should be equal")
  end


end
