class DonationType < ActiveRecord::Base
  has_many :donations

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }


end
