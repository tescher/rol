require 'test_helper'

class InterestsEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @interest = interests(:one)
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
    category = "Bar"
    patch interest_path(@interest), interest: { name:  name,
                                                   category: category,
                                  highlight: true}
    assert_not flash.empty?
    assert_redirected_to interests_url
    @interest.reload
    assert_equal @interest.name,  name
    assert_equal @interest.category,  category
    assert_equal @interest.highlight, true
  end

  test "successful edit with friendly forwarding" do
    get edit_interest_path(@interest)
    log_in_as(@user)
    assert_redirected_to edit_interest_path(@interest)
    name  = "Foo"
    category = "Bar"
    patch interest_path(@interest), interest: { name:  name,
                                                   category: category,
                                                   highlight: false }
    assert_not flash.empty?
    assert_redirected_to interests_url
    @interest.reload
    assert_equal @interest.name,  name
    assert_equal @interest.category,  category
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


end