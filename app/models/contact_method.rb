class ContactMethod < ActiveRecord::Base

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

end
