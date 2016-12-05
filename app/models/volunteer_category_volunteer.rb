class VolunteerCategoryVolunteer < ActiveRecord::Base
  belongs_to :volunteer
  belongs_to :volunteer_category
end
