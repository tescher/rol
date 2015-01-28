class Interest < ActiveRecord::Base
  has_many :volunteer_interests
  has_many :volunteers, through: :volunteer_interests
  belongs_to :interest_category

  validates :name, presence: true, uniqueness: {scope: :interest_category_id, message: "Duplicate name and category with another interest"}
  validates :interest_category_id, presence: true

  def option_formatter
    if self.inactive?
      "/#{self.name}"
    elsif self.highlight?
      "*#{self.name}"
    else
      self.name
    end
  end


end
