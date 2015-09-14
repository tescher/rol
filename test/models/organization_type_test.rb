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
end
