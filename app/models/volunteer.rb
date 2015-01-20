class Volunteer < ActiveRecord::Base
  before_save { self.email = email.downcase }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, allow_blank: true, format: { with: VALID_EMAIL_REGEX }

  def name
    [first_name, last_name].join(' ')
  end

end
