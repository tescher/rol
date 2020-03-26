class PendingVolunteer < ApplicationRecord
#   has_many :pending_volunteer_interests, dependent: :destroy
#   has_many :interests, through: :pending_volunteer_interests
#   belongs_to :volunteers
#   has_one :volunteer
#
#   before_save :save_phone
#
#   validates :first_name, presence: true
#   validates :last_name, presence: true
#
#   def name
#     [first_name, last_name].join(' ')
#   end
#
#   def self.resolve_fields_table
#     resolve_fields = {}
#     index = 0
#     [:first_name, :last_name, :address, :city, :state, :zip, :email, :home_phone, :work_phone, :mobile_phone].each do |f|
#       resolve_fields[f] = index
#       index += 1
#     end
#     resolve_fields
#   end
#
#   private
#
#   def save_phone
#     if self.phone
#       self.home_phone = self.phone
#       self.work_phone = self.phone
#       self.mobile_phone = self.phone
#     end
#   end
#
end
