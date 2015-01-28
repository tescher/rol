require 'test_helper'

class InterestsEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @interest = interests(:one)
    @interest_2 = interests(:two)
    @non_admin = users(:one)
  end

  test "No edits by non-admin" do
    log_in_as(@non_admin)
    get edit_interest_path(@interest)
    assert_redirected_to root_url
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_interest_path(@interest)
    assert_template 'interests/edit'
    patch interest_path(@interest), interest: { name:  "" }
    assert_template 'interests/edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_interest_path(@interest)
    assert_template 'interests/edit'
    name  = "Foo"
    interest_category_id = 2
    patch interest_path(@interest), interest: { name:  name,
                                                   interest_category_id: interest_category_id,
                                  highlight: true}
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
    patch interest_path(@interest), interest: { name:  name,
                                                interest_category_id: interest_category_id,
                                                   highlight: false }
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
  end

  test "no duplicate creation" do
    log_in_as(@user)
    get edit_interest_path(@interest_2)
    assert_template 'interests/edit'
    name  = @interest.name
    category = @interest.interest_category_id
    patch interest_path(@interest_2), interest: { name:  name, interest_category_id: category }
    assert_select '.alert', 1
    @interest_2.reload
    assert_not_equal @interest_2.name,  name

  end



end