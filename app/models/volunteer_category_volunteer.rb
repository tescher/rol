class VolunteerCategoryVolunteer < ApplicationRecord
  belongs_to :volunteer
  belongs_to :volunteer_category
end
