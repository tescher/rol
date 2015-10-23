class WorkdayVolunteer < ActiveRecord::Base
  belongs_to :workday
  belongs_to :volunteer

  validates :workday_id, presence: true
  validates :volunteer_id, presence: true
  validate :calc_and_validate_hours
  validates :hours, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true


  private

  def calc_and_validate_hours
    if !self.start_time.blank? || !self.end_time.blank?
      begin
        if self.start_time.blank? || self.end_time.blank?
          if !(self.hours.to_f > 0)
            self.hours = 4
          end
        else
          hours = ((self.end_time - self.start_time) / 3600).round(1)
          if hours < 0
            errors.add(:hours, "end time blank or before start time")
          else
            self.hours = hours
          end
        end
      rescue
        errors.add(:hours, "cannot calculate")
      end
    end
  end
end
