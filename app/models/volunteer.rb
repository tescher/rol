include ActionView::Helpers::NumberHelper

class Volunteer < ApplicationRecord
  acts_as_paranoid
  has_many :volunteer_interests, dependent: :destroy
  has_many :interests, through: :volunteer_interests
  has_many :workday_volunteers, dependent: :destroy
  has_many :workdays, through: :workday_volunteers
  has_many :donations, dependent: :destroy
  has_many :waivers, dependent: :destroy
  has_many :contacts, dependent: :destroy
  belongs_to :church, -> { where(:organization_type => 1) }, class_name: "Organization", foreign_key: :church_id
  belongs_to :employer, class_name: "Organization", foreign_key: :employer_id
  belongs_to :first_contact_type, class_name: "ContactType", foreign_key: :first_contact_type_id
  has_many :volunteer_category_volunteers, dependent: :destroy
  has_many :volunteer_categories, through: :volunteer_category_volunteers
  has_many :waivers_as_guardian, class_name: "Waiver", foreign_key: :guardian_id, dependent: :restrict_with_error
  # belongs_to :guardian, class_name: "Volunteer", foreign_key: :guardian_id
  # has_many :minors, class_name: "Volunteer", foreign_key: :guardian_id, dependent: :restrict_with_error
  has_many :homeowners_projects, dependent: :restrict_with_error
  has_many :homes, through: :homeowners_projects, source: :project

  default_scope { where(needs_review: false) }

  def self.pending
    Volunteer.unscoped.where(needs_review: true, deleted_at: nil)
  end

  # Special method for getting all volunteers including pending, but excluding the
  # deleted ones.
  def self.including_pending
    Volunteer.unscope(where: :needs_review)
    # Volunteer.unscoped.where(deleted_at: nil)
  end

  accepts_nested_attributes_for :donations, :allow_destroy => true
  accepts_nested_attributes_for :waivers, :allow_destroy => true
  accepts_nested_attributes_for :contacts, :allow_destroy => true


  before_save {
    self.email = email.downcase if email
    self.home_phone = number_to_phone(self.home_phone)
    self.work_phone = number_to_phone(self.work_phone)
    self.mobile_phone = number_to_phone(self.mobile_phone)
    self.emerg_contact_phone = number_to_phone(self.emerg_contact_phone)
  }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, allow_blank: true, format: { with: VALID_EMAIL_REGEX }
  validates_date :waiver_date, allow_blank: true
  validates_date :first_contact_date, allow_blank: true
  validates_date :background_check_date, allow_blank: true
  validates_date :birthdate, allow_blank: true
  validate :pending_must_allow_background_check
  validate :pending_need_age

  def name
    [first_name, last_name].join(' ')
  end

  def phone
    self.home_phone || self.mobile_phone || self.work_phone
  end

  def last_workday
    if self.id
      Workday.joins(:workday_volunteers).where("workday_volunteers.volunteer_id = '#{self.id}'").order("workdays.workdate DESC").first
    else
      nil
    end
  end

  def self.merge_fields_table
    merge_fields = {}
    index = 0
    [:first_name, :middle_name, :last_name, :occupation, :address, :city, :state, :zip, :email, :home_phone, :work_phone, :mobile_phone, :remove_from_mailing_list, :waiver_date, :background_check_date, :church_id, :primary_church_contact, :employer_id, :primary_employer_contact, :first_contact_date, :first_contact_type_id, :medical_conditions, :limitations, :emerg_contact_name, :emerg_contact_phone, :agree_to_background_check, :birthdate, :adult].each do |f|
      merge_fields[f] = index
      index += 1
    end
    merge_fields
  end

  def self.pending_volunteer_merge_fields_table
    resolve_fields = {}
    index = 0
    pending_volunteer_merge_fields.each do |f|
      resolve_fields[f] = index
      index += 1
    end
    puts resolve_fields
    resolve_fields
  end

  def self.pending_volunteer_merge_fields
    [:first_name, :last_name, :address, :city, :state, :occupation, :zip, :email, :home_phone, :work_phone, :mobile_phone, :emerg_contact_name, :emerg_contact_phone, :limitations, :medical_conditions, :agree_to_background_check, :birthdate, :adult]
  end

  # Returns a fuzzy match string that can be used in a where condition.  Generally used for
  # for first_name, last_name, and city fields.
  def self.get_fuzzymatch_where_clause(field_name, field_value)
    return "(soundex(#{field_name}) = soundex(#{self.sanitize(field_value)}) OR (LOWER(#{field_name}) LIKE #{self.sanitize(field_value.downcase+ "%")}))"
  end
  
  def autocomplete_display
    if self.city.blank? then
      "#{self.last_name}, #{self.first_name}"
    else
      "#{self.last_name}, #{self.first_name} (#{self.city})"
    end
    
  end

  def pending_must_allow_background_check
    if (self.needs_review == true) && (self.agree_to_background_check != true) && (self.deleted_reason.blank?)
      errors.add(:agree_to_background_check, "Must agree to allow a background check in order to apply.")
    end
  end
  def pending_need_age
    if (self.needs_review == true) && (self.adult != true) && (self.birthdate.blank?) && (self.deleted_reason.blank?)
      errors.add(:need_age, "Enter birthdate or check that you are #{Utilities::Utilities.system_setting(:adult_age)} or older.")
    end
  end

  def self.sanitize(string)
    "\'#{sanitize_sql(string)}\'"
  end


end
