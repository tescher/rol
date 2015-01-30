require 'test_helper'

class WorkdayTest < ActiveSupport::TestCase
  setup do
    @workday = workdays(:one)
  end

  model_test(@workday)

end
