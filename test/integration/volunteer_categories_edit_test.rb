require 'test_helper'

class VolunteerCategoriesEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @volunteer_category = volunteer_categories(:intern)
    @volunteer_category_2 = volunteer_categories(:huber)
    @volunteer_category_3 = VolunteerCategory.new(name: "Test")
    @volunteer_category_3.save
    @non_admin = users(:one)
  end

  def teardown
    @volunteer_category_3.destroy
  end

  test "No edits by non-admin" do
    log_in_as(@non_admin)
    get edit_volunteer_category_path(@volunteer_category)
    assert_redirected_to root_url
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_volunteer_category_path(@volunteer_category)
    assert_template 'shared/simple_edit'
    patch volunteer_category_path(@volunteer_category), volunteer_category: { name:  "" }
    assert_template 'shared/simple_edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_volunteer_category_path(@volunteer_category)
    assert_template 'shared/simple_edit'
    name  = "Foo"
    patch volunteer_category_path(@volunteer_category), volunteer_category: { name:  name }
    assert_not flash.empty?
    assert_redirected_to volunteer_categories_url
    @volunteer_category.reload
    assert_equal @volunteer_category.name,  name
  end

  test "successful edit with friendly forwarding" do
    get edit_volunteer_category_path(@volunteer_category)
    log_in_as(@user)
    assert_redirected_to edit_volunteer_category_path(@volunteer_category)
    name  = "Foo"
    patch volunteer_category_path(@volunteer_category), volunteer_category: { name:  name }
    assert_not flash.empty?
    assert_redirected_to volunteer_categories_url
    @volunteer_category.reload
    assert_equal @volunteer_category.name,  name
  end

  test "successful delete as admin" do
    log_in_as(@user)
    get edit_volunteer_category_path(@volunteer_category_3)
    assert_select 'a[href=?]', volunteer_category_path(@volunteer_category_3), method: :delete

    assert_difference 'VolunteerCategory.count', -1 do
      delete volunteer_category_path(@volunteer_category_3)
    end
  end

  test "no delete if attached to an volunteer" do
    log_in_as(@user)
    @volunteer = volunteers(:one)
    @volunteer.volunteer_categories = [@volunteer_category_3]
    @volunteer.save
    get edit_volunteer_category_path(@volunteer_category_3)
    assert_select 'a[href=?]', volunteer_category_path(@volunteer_category_3), method: :delete

    assert_no_difference 'VolunteerCategory.count' do
      delete volunteer_category_path(@volunteer_category_3)
    end
    VolunteerVolunteerCategory.where(volunteer_id: @volunteer.id).each do |vi|
      vi.destroy
    end
  end

  test "no duplicate creation" do
    log_in_as(@user)
    get edit_volunteer_category_path(@volunteer_category_2)
    assert_template 'shared/simple_edit'
    name  = @volunteer_category.name
    patch volunteer_category_path(@volunteer_category_2), volunteer_category: { name:  name }
    assert_select '.alert', 1
    @volunteer_category_2.reload
    assert_not_equal @volunteer_category_2.name,  name

  end


end