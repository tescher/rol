include ActionView::Helpers::NumberHelper

class Volunteer < ActiveRecord::Base
  has_many :volunteer_interests
  has_many :interests, through: :volunteer_interests
  has_many :workday_volunteers
  has_many :workdays, through: :workday_volunteers
  has_many :donations

  before_save {
    self.email = email.downcase if email
    self.home_phone = number_to_phone(self.home_phone)
    self.work_phone = number_to_phone(self.work_phone)
    self.mobile_phone = number_to_phone(self.mobile_phone)
  }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, allow_blank: true, format: { with: VALID_EMAIL_REGEX }
  validates_date :waiver_date, allow_blank: true
  validates_date :background_check_date, allow_blank: true

  def name
    [first_name, last_name].join(' ')
  end

end
