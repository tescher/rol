include ActionView::Helpers::NumberHelper

class Volunteer < ActiveRecord::Base
  before_save {
    self.email = email.downcase
    self.home_phone = number_to_phone(self.home_phone)
    self.work_phone = number_to_phone(self.work_phone)
    self.mobile_phone = number_to_phone(self.mobile_phone)
  }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, allow_blank: true, format: { with: VALID_EMAIL_REGEX }

  def name
    [first_name, last_name].join(' ')
  end

end