class Workday < ActiveRecord::Base
  belongs_to :project
  has_many :workday_volunteers

  validates :name, presence: true, uniqueness: { scope: [:project_id, :workdate], case_sensitive: false, message: "duplicate workday" }
  validates :project_id, presence: true
  validates :workdate, presence: true

end
