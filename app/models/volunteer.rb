include ActionView::Helpers::NumberHelper

class Volunteer < ActiveRecord::Base
  acts_as_paranoid
  has_many :volunteer_interests, dependent: :destroy
  has_many :interests, through: :volunteer_interests
  has_many :workday_volunteers, dependent: :destroy
  has_many :workdays, through: :workday_volunteers
  has_many :donations, dependent: :destroy
  has_many :waivers, dependent: :destroy
  belongs_to :church, -> { where(:organization_type => 1) }, class_name: "Organization", foreign_key: :church_id
  belongs_to :employer, class_name: "Organization", foreign_key: :employer_id
  belongs_to :first_contact_type, class_name: "ContactType", foreign_key: :first_contact_type_id
  has_many :volunteer_category_volunteers, dependent: :destroy
  has_many :volunteer_categories, through: :volunteer_category_volunteers
  belongs_to :guardian, class_name: "Volunteer", foreign_key: :guardian_id
  has_many :minors, class_name: "Volunteer", foreign_key: :guardian_id, dependent: :restrict_with_error

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


  before_save {
    self.email = email.downcase if email
    self.home_phone = number_to_phone(self.home_phone)
    self.work_phone = number_to_phone(self.work_phone)
    self.mobile_phone = number_to_phone(self.mobile_phone)
  }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, allow_blank: true, format: { with: VALID_EMAIL_REGEX }
  validates_date :waiver_date, allow_blank: true
  validates_date :first_contact_date, allow_blank: true
  validates_date :background_check_date, allow_blank: true

  def name
    [first_name, last_name].join(' ')
  end

  def phone
    self.home_phone || self.mobile_phone || self.work_phone
  end

  def self.merge_fields_table
    merge_fields = {}
    index = 0
    [:first_name, :middle_name, :last_name, :occupation, :address, :city, :state, :zip, :email, :home_phone, :work_phone, :mobile_phone, :remove_from_mailing_list, :waiver_date, :background_check_date, :church_id, :employer_id, :first_contact_date, :first_contact_type_id].each do |f|
      merge_fields[f] = index
      index += 1
    end
    merge_fields
  end

  def self.pending_volunteer_merge_fields_table
    resolve_fields = {}
    index = 0
    [:first_name, :last_name, :address, :city, :state, :zip, :email, :home_phone, :work_phone, :mobile_phone].each do |f|
      resolve_fields[f] = index
      index += 1
    end
    resolve_fields
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

end
