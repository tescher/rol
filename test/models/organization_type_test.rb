require 'test_helper'

class OrganizationTypeTest < ActiveSupport::TestCase

  def setup
    @organization_type = OrganizationType.new(name: "NGO")
  end

  def teardown
    @organization_type.destroy
  end

  test "should be valid" do
    assert @organization_type.valid?
  end

  test "name should be present, category doesn't matter" do
    @organization_type.name = "     "
    assert_not @organization_type.valid?
  end

  test "cannot change locked type" do
    @organization_type1 = OrganizationType.find(1)
    old_name = @organization_type1.name
    @organization_type1.name = "Something Else"
    assert_raises(ActiveRecord::ReadOnlyRecord) { @organization_type1.save}
    # assert_not @organization_type.errors.empty?, "Should error"
  end

  test "Organization Association" do
    @organization_type1 = organization_types(:master)
    @organization1 = volunteers(:dependent)
    assert_raises(ActiveRecord::DeleteRestrictionError) {@organization_type1.destroy}
  end

end
