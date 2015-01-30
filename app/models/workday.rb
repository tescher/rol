class Workday < ActiveRecord::Base
  belongs_to :project

  validates :name, presence: true, uniqueness: { scope: [:project_id, :workdate], case_sensitive: false, message: "duplicate workday" }

end
