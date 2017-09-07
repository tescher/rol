class Workday < ActiveRecord::Base

  attr_accessor :skip_dup_check

  belongs_to :project
  has_many :workday_volunteers, dependent: :destroy
  has_many :workday_organizations, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: [:project_id, :workdate], case_sensitive: false, message: ": duplicate workday", unless: :skip_dup_check? }
  validates :project_id, presence: true
  validates :workdate, presence: true

  accepts_nested_attributes_for :workday_volunteers, :reject_if => lambda { |a| a[:volunteer_id].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :workday_organizations, :reject_if => lambda { |a| a[:organization_id].blank? }, :allow_destroy => true

  def skip_dup_check?
    @skip_dup_check
  end

  def is_overlapping_volunteer(workday_volunteer)

    # Check overlapping in the current workday
    overlapping_shifts = self.workday_volunteers.where(
    "(volunteer_id = :volunteer_id) AND (id != :this_workday_volunteer_id) AND
    (start_time > :this_start_time) AND (:this_end_time >= start_time)",
    {
      volunteer_id: workday_volunteer.volunteer.id,
      this_workday_volunteer_id: workday_volunteer.id,
      this_start_time: workday_volunteer.start_time.strftime("%H:%M:%S"),
      this_end_time: workday_volunteer.end_time.strftime("%H:%M:%S")
    })

    overlapping_shifts.count > 0 ? true : false
  end

  def get_overlapping_workday(workday_volunteer)
    overlapping_shifts =
            Workday.joins(:workday_volunteers)
                  .where("workdays.workdate = :workdate AND
                  (workday_volunteers.volunteer_id = :volunteer_id) AND
                  (workdays.id != :id) AND (:this_end_time > workday_volunteers.start_time) AND
                  (workday_volunteers.end_time is null) ",
                  {
                    id: self.id,
                    workdate: self.workdate,
                    volunteer_id: workday_volunteer.volunteer.id,
                    this_workday_volunteer_id: workday_volunteer.id,
                    this_start_time: workday_volunteer.start_time.strftime("%H:%M:%S"),
                    this_end_time: workday_volunteer.end_time.strftime("%H:%M:%S")
                  })

      overlapping_shifts.count > 0 ? overlapping_shifts[0] : nil
  end

end
