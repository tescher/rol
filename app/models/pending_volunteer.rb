class PendingVolunteer < ActiveRecord::Base
  has_many :pending_volunteer_interests, dependent: :destroy
  has_many :interests, through: :pending_volunteer_interests

  validates :first_name, presence: true
  validates :last_name, presence: true

  def name
    [first_name, last_name].join(' ')
  end

end
