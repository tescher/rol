require 'test_helper'

class OrganizationsSearchTest < ActionDispatch::IntegrationTest

  def setup
    @user     = users(:one)
    @organization_type = OrganizationType.new(name: "Builder")
    @organization_type.save
    @organization_type2 = OrganizationType.new(name: "Bank")
    @organization_type2.save
  end

  def teardown
    @organization_type.destroy
    @organization_type2.destroy
  end

  test "Search including pagination" do
    log_in_as(@user)
    get search_organizations_path
    assert_template 'organizations/search'
    get organizations_path, {name: "e"}
    assert_select 'div.pagination'
    first_page_of_organizations = Organization.where("(soundex(name) = soundex('e') OR (LOWER(name) LIKE 'e%'))").order(:name, :city).paginate(page: 1, per_page: 29)
    # puts "Organization Count #{first_page_of_organizations.count}"
    # puts @response.body
    first_page_of_organizations.each do |organization|
      # puts organization.name
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
    @organization.destroy
  end

  test "Do not find organizations with wrong type" do
    log_in_as(@user)
    @organization = Organization.new(name: "Escher Builders", contact_name: "Tim Escher", email: "tim@eschers.com", organization_type_id: @organization_type.id)
    @organization.save
    get search_organizations_path
    assert_template 'organizations/search'
    get organizations_path, {organization_type_ids: [@organization_type2.id]}
    assert_select 'div[href=?]', edit_organization_path(@organization), false
    @organization.destroy
  end


  test "Find organizations with type and name" do
    log_in_as(@user)
    @organization = Organization.new(name: "Escher Builders", contact_name: "Tim Escher", email: "tim@eschers.com", organization_type_id: @organization_type.id)
    @organization.save
    get search_organizations_path
    assert_template 'organizations/search'
    get organizations_path, {organization_type_ids: [@organization_type.id], name: "e"}
    assert_select 'div[href=?]', edit_organization_path(@organization)
    @organization.destroy
  end


end