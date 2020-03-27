class Project < ApplicationRecord
  has_many :workdays, dependent: :restrict_with_exception

  has_many :homeowners_projects, dependent: :restrict_with_error
  has_many :homeowners, through: :homeowners_projects, source: :volunteer

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

  scope :active, -> { where(inactive: false) }

  def last_workday
    Workday.where("project_id = '#{self.id}'").order("workdate DESC").first
  end

end
