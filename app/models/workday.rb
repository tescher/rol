class Workday < ActiveRecord::Base

  attr_accessor :skip_dup_check

  belongs_to :project
  has_many :workday_volunteers, dependent: :destroy
  has_many :workday_organizations, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: [:project_id, :workdate], case_sensitive: false, message: ": duplicate workday", on: :create, unless: :skip_dup_check? }
  validates :project_id, presence: true
  validates :workdate, presence: true

  accepts_nested_attributes_for :workday_volunteers, :reject_if => lambda { |a| a[:volunteer_id].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :workday_organizations, :reject_if => lambda { |a| a[:organization_id].blank? }, :allow_destroy => true

  def skip_dup_check?
    @skip_dup_check
  end

end
