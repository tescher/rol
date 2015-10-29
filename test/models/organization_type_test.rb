require 'test_helper'

class OrganizationTypeTest < ActiveSupport::TestCase

  def setup
    @organization_type = OrganizationType.new(name: "NGO")
  end

  test "should be valid" do
    assert @organization_type.valid?
  end

  test "name should be present, category doesn't matter" do
    @organization_type.name = "     "
    assert_not @organization_type.valid?
  end

  test "cannot change locked type" do
    @organization_type = OrganizationType.find(1)
    old_name = @organization_type.name
    @organization_type.name = "Something Else"
    assert_raises(ActiveRecord::ReadOnlyRecord) { @organization_type.save}
    # assert_not @organization_type.errors.empty?, "Should error"
  end

  test "Organization Association" do
    @organization_type = organization_types(:master)
    @organization = volunteers(:dependent)
    assert_raises(ActiveRecord::DeleteRestrictionError) {@organization_type.destroy}
  end

end
