require 'test_helper'

class ContactTypeTest < ActiveSupport::TestCase

  test "Volunteer Association" do
    @contact_type = contact_types(:master)
    @volunteer = volunteers(:dependent)
    assert_raises(ActiveRecord::DeleteRestrictionError) {@contact_type.destroy}
  end

end
