require 'test_helper'

class OrganizationTypesEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @organization_type = organization_types(:non_profit)
    @organization_type_2 = organization_types(:business)
    @organization_type_3 = OrganizationType.new(name: "Test")
    @organization_type_3.save
    @non_admin = users(:one)
  end

  test "No edits by non-admin" do
    log_in_as(@non_admin)
    get edit_organization_type_path(@organization_type)
    assert_redirected_to root_url
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_organization_type_path(@organization_type)
    assert_template 'organization_types/edit'
    patch organization_type_path(@organization_type), organization_type: { name:  "" }
    assert_template 'organization_types/edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_organization_type_path(@organization_type)
    assert_template 'organization_types/edit'
    name  = "Foo"
    patch organization_type_path(@organization_type), organization_type: { name:  name }
    assert_not flash.empty?
    assert_redirected_to organization_types_url
    @organization_type.reload
    assert_equal @organization_type.name,  name
  end

  test "successful edit with friendly forwarding" do
    get edit_organization_type_path(@organization_type)
    log_in_as(@user)
    assert_redirected_to edit_organization_type_path(@organization_type)
    name  = "Foo"
    patch organization_type_path(@organization_type), organization_type: { name:  name }
    assert_not flash.empty?
    assert_redirected_to organization_types_url
    @organization_type.reload
    assert_equal @organization_type.name,  name
  end

  test "successful delete as admin" do
    log_in_as(@user)
    get edit_organization_type_path(@organization_type_3)
    assert_select 'a[href=?]', organization_type_path(@organization_type_3), method: :delete

    assert_difference 'OrganizationType.count', -1 do
      delete organization_type_path(@organization_type_3)
    end
  end

  test "no delete if attached to an organization" do
    log_in_as(@user)
    @organization = organizations(:one)
    @organization.organization_type = @organization_type
    @organization.save
    get edit_organization_type_path(@organization_type)
    assert_select 'a[href=?]', organization_type_path(@organization_type), method: :delete

    assert_no_difference 'OrganizationType.count' do
      delete organization_type_path(@organization_type)
    end
  end

  test "no duplicate creation" do
    log_in_as(@user)
    get edit_organization_type_path(@organization_type_2)
    assert_template 'organization_types/edit'
    name  = @organization_type.name
    patch organization_type_path(@organization_type_2), organization_type: { name:  name }
    assert_select '.alert', 1
    @organization_type_2.reload
    assert_not_equal @organization_type_2.name,  name

  end


end