class Project < ActiveRecord::Base
  has_many :workdays

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

end
