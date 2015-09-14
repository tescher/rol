require 'test_helper'

class OrganizationsEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @organization = organizations(:one)
    @admin = users(:michael)
    @non_admin = users(:one)
  end

  test "No imports by non-admin" do
    log_in_as(@non_admin)
    get import_organizations_path
    assert_redirected_to root_url
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_organization_path(@organization)
    assert_template 'organizations/edit'
    patch organization_path(@organization), organization: { name:  "",
                                    email: "foo@invalid" }
    assert_template 'organizations/edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_organization_path(@organization)
    assert_template 'organizations/edit'
    name  = "Foo"
    email = "foo@bar.com"
    patch organization_path(@organization), organization: { name:  first_name,
                                                   email: email }
    assert_not flash.empty?
    assert_redirected_to search_organizations_url
    @organization.reload
    assert_equal @organization.name,  name
    assert_equal @organization.email, email
  end

  test "successful edit with friendly forwarding" do
    get edit_organization_path(@organization)
    log_in_as(@user)
    assert_redirected_to edit_organization_path(@organization)
    name  = "Foo"
    email = "foo@bar.com"
    patch organization_path(@organization), organization: { name:  name,
                                                   email: email }
    assert_not flash.empty?
    assert_redirected_to search_organizations_url
    @organization.reload
    assert_equal @organization.name,  name
    assert_equal @organization.email, email
  end

  test "successful delete as admin" do
    log_in_as(@admin)
    get edit_organization_path(@organization)
    assert_select 'a[href=?]', organization_path(@organization), method: :delete

    assert_difference 'Organization.count', -1 do
      delete organization_path(@organization)
    end

  end

  test "No delete if not admin" do
    log_in_as(@user)
    get edit_organization_path(@organization)
    assert_no_match 'a[href=?]', organization_path(@organization), method: :delete
  end


end