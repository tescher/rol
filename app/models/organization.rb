include ActionView::Helpers::NumberHelper
include ApplicationHelper

class Organization < ApplicationRecord
  belongs_to :organization_type
  has_many :workday_organizations, dependent: :destroy
  has_many :workdays, through: :workday_organizations
  has_many :donations, dependent: :destroy
  has_many :church_members, class_name: "Volunteer", foreign_key: :church_id, dependent: :restrict_with_exception
  has_many :employees, class_name: "Volunteer", foreign_key: :employer_id, dependent: :restrict_with_exception


  accepts_nested_attributes_for :donations, :allow_destroy => true


  before_save {
    self.email = email.downcase if email
    self.phone = number_to_phone(self.phone)
  }

  validates :name, presence: true
  validate :check_email
  validates :organization_type_id, presence: true

  def check_email
    if email.present?
      errors[:email] << "is not valid" unless multi_email_valid(email)
    end
  end

  def autocomplete_display
    if self.city.blank? then
      "#{self.name}"
    else
      "#{self.name} (#{self.city})"
      end
  end

  def self.sanitize(string)
    "\'#{sanitize_sql(string)}\'"
  end

end
