include ActionView::Helpers::NumberHelper

class Volunteer < ActiveRecord::Base
  acts_as_paranoid
  has_many :volunteer_interests, dependent: :destroy
  has_many :interests, through: :volunteer_interests
  has_many :workday_volunteers, dependent: :destroy
  has_many :workdays, through: :workday_volunteers
  has_many :donations, dependent: :destroy
  has_one :pending_volunteer
  belongs_to :pending_volunteer
  belongs_to :church, -> { where(:organization_type => 1) }, class_name: "Organization", foreign_key: :church_id
  belongs_to :employer, class_name: "Organization", foreign_key: :employer_id
  belongs_to :first_contact_type, class_name: "ContactType", foreign_key: :first_contact_type_id
  has_and_belongs_to_many :volunteer_categories


  accepts_nested_attributes_for :donations, :allow_destroy => true


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

end
