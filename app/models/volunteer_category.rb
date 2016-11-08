class VolunteerCategory < ActiveRecord::Base
  has_and_belongs_to_many :volunteers, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

end
