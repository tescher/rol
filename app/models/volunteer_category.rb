class VolunteerCategory < ActiveRecord::Base
  has_many :volunteer_category_volunteers, dependent: :restrict_with_exception
  has_many :volunteers, through: :volunteer_category_volunteers, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

end
