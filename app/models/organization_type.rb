class OrganizationType < ActiveRecord::Base
  has_many :organizations

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

  def readonly?
    LOCKED_ORGANIZATION_TYPES.include?(self.id)
  end


end
