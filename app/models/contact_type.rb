class ContactType < ApplicationRecord
  has_many :volunteers, foreign_key: :first_contact_type_id, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }


end
