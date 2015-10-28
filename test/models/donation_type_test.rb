require 'test_helper'

class DonationTypeTest < ActiveSupport::TestCase

  test "Donation Association" do
    @donation_type = donation_types(:master)
    @donation = donations(:dependent)
    assert_raises(ActiveRecord::DeleteRestrictionError) {@donation_type.destroy}
  end

end
