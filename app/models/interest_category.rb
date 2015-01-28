class InterestCategory < ActiveRecord::Base
  has_many :interests

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

end
