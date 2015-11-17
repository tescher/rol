class PendingVolunteer < ActiveRecord::Base
  has_many :pending_volunteer_interests, dependent: :destroy
  has_many :interests, through: :pending_volunteer_interests
  belongs_to :volunteers
  has_one :volunteer

  validates :first_name, presence: true
  validates :last_name, presence: true

  def name
    [first_name, last_name].join(' ')
  end

  def self.resolve_fields_table
    resolve_fields = {}
    index = 0
    [:first_name, :last_name, :address, :city, :state, :zip, :email, :phone].each do |f|
      resolve_fields[f] = index
      index += 1
    end
    resolve_fields
  end

end
