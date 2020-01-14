class ContactMethod < ApplicationRecord
  has_many :contacts, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

end
