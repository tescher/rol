class Project < ApplicationRecord
  has_many :workdays, dependent: :restrict_with_error

  has_many :homeowner_projects, dependent: :restrict_with_error
  has_many :homeowners, through: :homeowner_projects, source: :volunteer
  accepts_nested_attributes_for :homeowner_projects, :reject_if => lambda { |a| a[:volunteer_id].blank? }, :allow_destroy => true


  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

  scope :active, -> { where(inactive: false) }

  def last_workday
    Workday.where("project_id = '#{self.id}'").order("workdate DESC").first
  end

end
