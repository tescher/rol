class WorkdayOrganization < ApplicationRecord
  belongs_to :workday
  belongs_to :organization

  validates :workday_id, presence: true
  validates :organization_id, presence: true
  validates :hours, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  validates :num_volunteers, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true


  validate :calc_and_validate_hours

  private

  def calc_and_validate_hours
    if !self.start_time.blank? || !self.end_time.blank?
      begin
        hours = ((self.end_time - self.start_time) / 3600).round(1)
        if hours < 0
          errors.add(:hours, "end time blank or before start time")
        else
          self.hours = hours
        end
      rescue
        errors.add(:hours, "cannot calculate")
      end
    end
  end
end
