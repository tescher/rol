include ActionView::Helpers::NumberHelper

class Organization < ActiveRecord::Base
  belongs_to :organization_type

  before_save {
    self.email = email.downcase if email
    self.phone = number_to_phone(self.phone)
  }

  validates :name, presence: true
  validates :email, allow_blank: true, format: { with: VALID_EMAIL_REGEX }
  validates :organization_type_id, presence: true

end
