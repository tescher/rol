require 'test_helper'

class ContactMethodTest < ActiveSupport::TestCase
  def setup
    @contact_method = ContactMethod.new(name: "Call")
  end

  def teardown
    @contact_method.destroy
  end

  test "should be valid" do
    assert @contact_method.valid?
  end

  test "name should be present" do
    @contact_method.name = "     "
    assert_not @contact_method.valid?
  end

  test "Contact Association" do
    @contact_method1 = contact_methods(:master)
    @contact1 = contacts(:dependent)
    assert_raises(ActiveRecord::DeleteRestrictionError) {@contact_method1.destroy}
  end
end
