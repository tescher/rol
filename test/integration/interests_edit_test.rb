require 'test_helper'

class InterestsEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @interest = Interest.create!(name:"test1", interest_category_id: 1)
    @interest_2 = Interest.create!(name:"test2", interest_category_id: 1)
    @non_admin = users(:one)
  end

  def teardown
    @interest.destroy
    @interest_2.destroy
  end

  test "No edits by non-admin" do
    log_in_as(@non_admin)
    get edit_interest_path(@interest)
    assert_redirected_to root_url
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_interest_path(@interest)
    assert_template 'shared/simple_edit'
    patch interest_path(@interest), interest: { name:  "" }
    assert_template 'shared/simple_edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_interest_path(@interest)
    assert_template 'shared/simple_edit'
    name  = "Foo"
    interest_category_id = 2
    patch interest_path(@interest), params: { interest: { name:  name,
                                                   interest_category_id: interest_category_id,
                                  highlight: true} }
    assert_not flash.empty?
    assert_redirected_to interests_url
    @interest.reload
    assert_equal @interest.name,  name
    assert_equal @interest.interest_category_id,  interest_category_id
    assert_equal @interest.highlight, true
  end

  test "successful edit with friendly forwarding" do
    get edit_interest_path(@interest)
    log_in_as(@user)
    assert_redirected_to edit_interest_path(@interest)
    name  = "Foo"
    interest_category_id = 2
    patch interest_path(@interest), params: { interest: { name:  name,
                                                interest_category_id: interest_category_id,
                                                   highlight: false } }
    assert_not flash.empty?
    assert_redirected_to interests_url
    @interest.reload
    assert_equal @interest.name,  name
    assert_equal @interest.interest_category_id,  interest_category_id
    assert_equal @interest.highlight, false
  end

  test "successful delete as admin" do
    log_in_as(@user)
    get edit_interest_path(@interest)
    assert_select 'a[href=?]', interest_path(@interest), method: :delete

    assert_difference 'Interest.count', -1 do
      delete interest_path(@interest)
    end
  end

  test "no delete if attached to a volunteer" do
    log_in_as(@user)
    @volunteer = volunteers(:one)
    @volunteer.interests = [@interest]
    @volunteer.save
    get edit_interest_path(@interest)
    assert_select 'a[href=?]', interest_path(@interest), method: :delete

    assert_no_difference 'Interest.count' do
      delete interest_path(@interest)
    end
    VolunteerInterest.where(volunteer_id: @volunteer.id).each do |vi|
      vi.destroy
    end
  end

  test "no duplicate creation" do
    log_in_as(@user)
    get edit_interest_path(@interest_2)
    assert_template 'shared/simple_edit'
    name  = @interest.name
    category = @interest.interest_category_id
    patch interest_path(@interest_2), params: { interest: { name:  name, interest_category_id: category } }
    assert_select '.alert', 1
    @interest_2.reload
    assert_not_equal @interest_2.name,  name

  end



end