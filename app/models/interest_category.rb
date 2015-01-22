class InterestCategory < ActiveRecord::Base
  has_many :interests

  validates :name, presence: true

end
