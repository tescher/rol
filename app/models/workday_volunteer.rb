class WorkdayVolunteer < ActiveRecord::Base
  belongs_to :workday
  belongs_to :volunteer
end
