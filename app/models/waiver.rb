class Waiver < ActiveRecord::Base
  belongs_to :volunteer
  belongs_to :guardian, class_name: "Volunteer", foreign_key: :guardian_id
  acts_as_paranoid

  validates_date :date_signed, on_or_before: lambda { Date.today }, allow_blank: false
  validates_date :birthdate, allow_blank: true
  validate :check_age_or_guardian_recorded
  validate :e_sign_includes_text

  private

  def check_age_or_guardian_recorded
    if !self.adult && !self.birthdate.present? && !self.guardian_id.present?
      errors.add(:adult, "Volunteer must be marked as an adult or have a recorded birthdate")
    end
  end

  def e_sign_includes_text
    if self.e_sign && !self.waiver_text.present?
      errors.add(:waiver_text, "E-signed waiver must include waiver text")
    end
  end
end
