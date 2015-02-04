class Workday < ActiveRecord::Base
  belongs_to :project
  has_many :workday_volunteers, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: [:project_id, :workdate], case_sensitive: false, message: "duplicate workday" }
  validates :project_id, presence: true
  validates :workdate, presence: true

  accepts_nested_attributes_for :workday_volunteers, :reject_if => lambda { |a| a[:volunteer_id].blank? }, :allow_destroy => true

end
