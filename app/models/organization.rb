include ActionView::Helpers::NumberHelper
include ApplicationHelper

class Organization < ActiveRecord::Base
  belongs_to :organization_type

  before_save {
    self.email = email.downcase if email
    self.phone = number_to_phone(self.phone)
  }

  validates :name, presence: true
  validate :check_email
  validates :organization_type_id, presence: true

  def check_email
    if email.present?
      errors[:email] << "is not valid" unless multi_email_valid(email)
    end
  end
end
