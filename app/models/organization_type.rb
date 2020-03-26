class OrganizationType < ApplicationRecord
  has_many :organizations, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "duplicate name" }

  def readonly?
    LOCKED_ORGANIZATION_TYPES.include?(self.id)
  end


end
