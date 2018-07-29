class Waiver < ActiveRecord::Base
  belongs_to :volunteer
  belongs_to :guardian, class_name: "Volunteer", foreign_key: :guardian_id
  acts_as_paranoid

  validates_date :date_signed, on_or_before: lambda { Date.today }, allow_blank: false
  validates_date :birthdate, allow_blank: true
  validate :check_age_or_guardian_recorded


  private

  def check_age_or_guardian_recorded
    if (self.adult != true) && !self.birthdate.present? && !self.guardian_id.present?
      errors.add(:adult, "Volunteer must be marked as an adult, have a recorded birthdate, or waiver signed by a guardian")
    end
  end

end
