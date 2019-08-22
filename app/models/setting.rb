class Setting < ActiveRecord::Base
  before_validation :default_values

  validates :min_password_length, numericality: { only_integer: true, greater_than: 0 }
  validates :records_per_page, numericality: { only_integer: true, greater_than: 0 }
  validates :waiver_valid_days, numericality: { only_integer: true, greater_than: 0 }
  validates :adult_age, numericality: { only_integer: true, greater_than: 0 }
  validate :check_email

  def check_email
    if pending_volunteer_notify_email.present?
      errors[:pending_volunteer_notify_email] << "is not valid (user commas between multiple addresses)" unless multi_email_valid(pending_volunteer_notify_email, true)
    end
  end

  private

  def default_values
    self.no_pagination = true if self.no_pagination.nil?
    self.records_per_page = 15 if self.records_per_page.nil?
    self.min_password_length = 6 if self.min_password_length.nil?
    self.adult_age = 18 if self.adult_age.nil?
    self.waiver_valid_days = 365 if self.waiver_valid_days.nil?
  end

end
