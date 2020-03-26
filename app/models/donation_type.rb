class DonationType < ApplicationRecord
  has_many :donations, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

  def option_formatter
    name = self.name + (self.non_monetary? ? " (non-monetary)" : "")
    if self.inactive?
      "/#{name}"
    else
      name
    end
  end


end
