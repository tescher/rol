class ContactType < ActiveRecord::Base
  has_many :volunteers

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }


end
