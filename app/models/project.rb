class Project < ActiveRecord::Base
  has_many :workdays, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

  scope :active, -> { where(inactive: false) }

  def last_workday
    Workday.where("project_id = '#{self.id}'").order("workdate DESC").first
  end

end
