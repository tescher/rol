require 'test_helper'

class OrganizationsSearchTest < ActionDispatch::IntegrationTest

  def setup
    @user     = users(:one)
    @organization_type = OrganizationType.new(name: "Builder")
    @organization_type.save
  end

  test "Search including pagination" do
    log_in_as(@user)
    get search_organizations_path
    assert_template 'organizations/search'
    get organizations_path, {name: "e"}
    assert_select 'div.pagination'
    first_page_of_organizations = Organization.paginate(page: 1)
    first_page_of_organizations.each do |organization|
      assert_select 'div[href=?]', edit_organization_path(organization)
    end
  end

  test "Find organizations with type" do
    log_in_as(@user)
    @organization = Organization.new(name: "Escher Builders", contact_name: "Tim Escher", email: "tim@eschers.com", organization_type_id: @organization_type.id)
    @organization.save
    get search_organizations_path
    assert_template 'organizations/search'
    get organizations_path, {organization_type_ids: [@organization_type.id]}
    assert_select 'div[href=?]', edit_organization_path(@organization)
  end

  test "Find organizations with type and name" do
    log_in_as(@user)
    @organization = Organization.new(name: "Escher Builders", contact_name: "Tim Escher", email: "tim@eschers.com", organization_type_id: @organization_type.id)
    @organization.save
    get search_organizations_path
    assert_template 'organizations/search'
    get organizations_path, {organization_type_ids: [@organization_type.id], name: "e"}
    assert_select 'div[href=?]', edit_organization_path(@organization)
  end


end