require 'test_helper'

class PendingVolunteersTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @volunteer = volunteers(:one)
    @pending_volunteer = volunteers(:pending_one)
    @non_admin = users(:one)

    @first_workday = workdays(:one)
    @second_workday = workdays(:two)

    interest1 = interests(:one)
    interest2 = interests(:two)
    interest3 = interests(:three)
    category1 = volunteer_categories(:intern)
    category2 = volunteer_categories(:huber)
    category3 = volunteer_categories(:master)
    [@volunteer, @pending_volunteer].each do |v|
      5.times do |n|
        Donation.create(donation_type: donation_types(:cash), volunteer_id: v.id, value: 10.00, date_received: n.day.ago.to_s(:db))
      end
      5.times do |n|
        Donation.create(donation_type: donation_types(:restore), volunteer_id: v.id, date_received: n.day.ago.to_s(:db))
      end
      WorkdayVolunteer.create(workday: @first_workday, volunteer: v, hours: 4)
      WorkdayVolunteer.create(workday: @second_workday, volunteer: v, hours: 4)
      if (v == @volunteer)
        VolunteerInterest.create(volunteer: v, interest: interest1)
        VolunteerInterest.create(volunteer: v, interest: interest2)
        VolunteerCategoryVolunteer.create(volunteer: v, volunteer_category: category1)
        VolunteerCategoryVolunteer.create(volunteer: v, volunteer_category: category2)
      else
        VolunteerInterest.create(volunteer: v, interest: interest2)
        VolunteerInterest.create(volunteer: v, interest: interest3)
        VolunteerCategoryVolunteer.create(volunteer: v, volunteer_category: category2)
        VolunteerCategoryVolunteer.create(volunteer: v, volunteer_category: category3)
      end
    end
  end

  def teardown
    [@volunteer, @pending_volunteer].each do |v|
      Donation.where("volunteer_id = #{v.id}").destroy_all
      WorkdayVolunteer.where("volunteer_id = #{v.id}").destroy_all
      VolunteerInterest.where("volunteer_id = #{v.id}").destroy_all
      VolunteerCategoryVolunteer.where("volunteer_id = #{v.id}").destroy_all
      # v.really_destroy!
    end
  end

  test "Should display recpatcha" do
    get new_pending_volunteer_path()
    assert_select "[class='g-recaptcha']"
  end

  test "Should not display recpatcha" do
    log_in_as(@user)
    get self_tracking_launch_path(@first_workday.id)
    get new_pending_volunteer_path()
    assert_select "[class='g-recaptcha']", false
  end

  test "New volunteer from pending volunteer with workdays" do
    log_in_as(@user)

    # Confirm the workdays
    assert_equal 2, @pending_volunteer.workday_volunteers.count

    get new_volunteer_path(pending_volunteer_id: @pending_volunteer)
    assert_template 'new'
    assert_select "[name*=first_name]" do
      assert_select "[value=?]", @pending_volunteer.first_name
    end
    volunteer = Volunteer.new()
    post volunteers_path(volunteer), volunteer: {
        first_name: @pending_volunteer.first_name,
        last_name: @pending_volunteer.last_name, pending_volunteer_id: @pending_volunteer.id
    }
    updated_volunteer = Volunteer.find(@pending_volunteer.id)
    assert_equal 2, updated_volunteer.workday_volunteers.count
    assert_equal @pending_volunteer.first_name, updated_volunteer.first_name
    assert_equal @pending_volunteer.last_name, updated_volunteer.last_name
    assert_equal false, updated_volunteer.needs_review
    assert_nil updated_volunteer.deleted_at
  end


  test "Merge pending volunteer into volunteer, with use fields" do  # pending_volunteer is the source, volunteer is the target
    log_in_as(@non_admin)

    # Merge all fields
    source_use_field_list = Volunteer.pending_volunteer_merge_fields_table
    merge_pending(source_use_field_list)
  end

  test "Merge pending volunteer into volunteer, with no use fields" do  # pending_volunteer is the source, volunteer is the target
    log_in_as(@non_admin)

    # Merge no fields
    merge_pending([])
  end

  def merge_pending(source_use_field_list)
    source_volunteer = @pending_volunteer
    target_volunteer = @volunteer

    workdays = WorkdayVolunteer.where("volunteer_id = #{source_volunteer.id}").all
    workdays_count = workdays.count # Need to do here to make sure query runs before merge
    workdays_dup = WorkdayVolunteer.where("volunteer_id = #{target_volunteer.id}").all
    workdays_dup_count = workdays_dup.count
    volunteer_interests = VolunteerInterest.where("volunteer_id = #{source_volunteer.id}").all
    volunteer_interests_count = volunteer_interests.count
    volunteer_interests_dup = VolunteerInterest.where("volunteer_id = #{target_volunteer.id}").all
    volunteer_interests_dup_count = volunteer_interests_dup.count
    donations_dup = Donation.where("volunteer_id = #{target_volunteer.id}").all
    donations_dup_count = donations_dup.count
    notes = source_volunteer.notes
    volunteer_category_volunteers = VolunteerCategoryVolunteer.where("volunteer_id = #{source_volunteer.id}").all
    volunteer_category_volunteers_count = volunteer_category_volunteers.count

    source_use_fields = source_use_field_list.map {|f,i| Volunteer.pending_volunteer_merge_fields_table[f] }

    use_notes = "ignore"   # Skip notes and interests and categories on this first pass
    use_limitations = "ignore"
    use_medical_conditions = "ignore"
    use_interests = "ignore"
    use_categories = "ignore"

    put pending_volunteer_path(source_volunteer), {
        matching_id: target_volunteer.id, pv_use_fields: source_use_fields, use_notes: use_notes, use_limitations: use_limitations, use_medical_conditions: use_medical_conditions,
        use_interests: use_interests, use_categories: use_categories,
        volunteer: {
            first_name: source_volunteer.first_name,
            last_name: source_volunteer.last_name,
            home_phone: source_volunteer.home_phone,
            adult: source_volunteer.adult,
            birthdate: source_volunteer.birthdate,
            agree_to_background_check: source_volunteer.agree_to_background_check,
            interest_ids: [source_volunteer.interest_ids]
        }
    }

    # Did everything delete OK?
    source_volunteer.reload
    target_volunteer.reload
    assert_equal  "Merged pending volunteer into #{target_volunteer.id}", source_volunteer.deleted_reason
    assert_not_nil source_volunteer.deleted_at
    assert_nil target_volunteer.deleted_reason
    assert_nil target_volunteer.deleted_at

    # Did all fields merge as expected?
    Volunteer.pending_volunteer_merge_fields_table.each do |field,index|
      if source_use_field_list.include? field
        assert_equal source_volunteer[field], target_volunteer[field], "Field #{field.to_s} should be equal"
      else
        assert_not_equal(source_volunteer[field], target_volunteer[field],"Field #{field.to_s} should not be equal") unless source_volunteer[field].nil? and target_volunteer[field].nil?
      end
    end

    # Did workdays move?
    assert_equal(
        WorkdayVolunteer.where("volunteer_id = #{target_volunteer.id}").all.count,
        workdays_count + workdays_dup_count,
        "Number of workdays (#{workdays_count + workdays_dup_count}) should be equal"
    )

    # Donations should not be affected.
    assert_equal(
        donations_dup_count,
        Donation.where("volunteer_id = #{target_volunteer.id}").all.count,
        "Number of donations should not have changed"
    )

    # We had "ignore" for notes and interests and categories, make sure they stayed as is
    assert_nil source_volunteer.notes, "Notes '#{notes}' should have remained as is"

    assert(
        volunteer_interests.uniq.sort == VolunteerInterest.where("volunteer_id = #{source_volunteer.id}").all.uniq.sort,
        "Interests (#{volunteer_interests_count}) should have remained the same"
    )
    assert(
        volunteer_category_volunteers.uniq.sort == VolunteerCategoryVolunteer.where("volunteer_id = #{source_volunteer.id}").all.uniq.sort,
        "Categories (#{volunteer_category_volunteers_count}) should have remained the same"
    )

    assert_equal 0, WorkdayVolunteer.where("volunteer_id = #{source_volunteer.id}").count, "All workday shifts from source gone"
    assert_equal 0, VolunteerInterest.where("volunteer_id = #{source_volunteer.id}").count, "All interests from source gone"
    assert_equal 0, VolunteerCategoryVolunteer.where("volunteer_id = #{source_volunteer.id}").count, "All categories from source gone"
  end
end
