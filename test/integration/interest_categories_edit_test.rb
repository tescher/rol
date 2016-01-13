require 'test_helper'

class InterestCategoriesEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @interest_category = interest_categories(:office)
    @interest_category_2 = interest_categories(:construction)
    @interest_category_deleteable = InterestCategory.new(name: "Deleteable")
    @interest_category_deleteable.save!
    @non_admin = users(:one)
  end

  def teardown
    @interest_category_deleteable.destroy
  end

  test "No edits by non-admin" do
    log_in_as(@non_admin)
    get edit_interest_category_path(@interest_category)
    assert_redirected_to root_url
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_interest_category_path(@interest_category)
    assert_template 'shared/simple_edit'
    patch interest_category_path(@interest_category), interest_category: { name:  "" }
    assert_template 'shared/simple_edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_interest_category_path(@interest_category)
    assert_template 'shared/simple_edit'
    name  = "Foo"
    patch interest_category_path(@interest_category), interest_category: { name:  name }
    assert_not flash.empty?
    assert_redirected_to interest_categories_url
    @interest_category.reload
    assert_equal @interest_category.name,  name
  end

  test "successful edit with friendly forwarding" do
    get edit_interest_category_path(@interest_category)
    log_in_as(@user)
    assert_redirected_to edit_interest_category_path(@interest_category)
    name  = "Foo"
    patch interest_category_path(@interest_category), interest_category: { name:  name }
    assert_not flash.empty?
    assert_redirected_to interest_categories_url
    @interest_category.reload
    assert_equal @interest_category.name,  name
  end

  test "successful delete as admin" do
    log_in_as(@user)
    get edit_interest_category_path(@interest_category_deleteable)
    assert_select 'a[href=?]', interest_category_path(@interest_category_deleteable), method: :delete

    assert_difference 'InterestCategory.count', -1 do
      delete interest_category_path(@interest_category_deleteable)
    end
  end

  test "no delete if attached to an interest" do
    log_in_as(@user)
    @interest = Interest.new(name: "Deletable")
    @interest.interest_category = @interest_category_deleteable
    @interest.save
    get edit_interest_category_path(@interest_category_deleteable)
    assert_select 'a[href=?]', interest_category_path(@interest_category_deleteable), method: :delete

    assert_no_difference 'InterestCategory.count' do
      delete interest_category_path(@interest_category_deleteable)
    end
    @interest.destroy
  end

  test "no duplicate creation" do
    log_in_as(@user)
    get edit_interest_category_path(@interest_category_2)
    assert_template 'shared/simple_edit'
    name  = @interest_category.name
    patch interest_category_path(@interest_category_2), interest_category: { name:  name }
    assert_select '.alert', 1
    @interest_category_2.reload
    assert_not_equal @interest_category_2.name,  name

  end


end