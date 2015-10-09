class Donation < ActiveRecord::Base
  belongs_to :donation_type
  belongs_to :volunteer
  belongs_to :organization


  attr_accessor :skip_item_check

  validates_date :date_received, allow_blank: false
  validates :donation_type, presence: true
  validate :have_donor
  validate :value_if_monetary
  validate :item_if_non_monetary, unless: :skip_item_check
  validate :value_not_negative

  private

  def have_donor
    errors.add(:volunteer_id, "missing volunteer or organization") unless !self.volunteer_id.nil? ^ !self.organization_id.nil?
  end

  def value_if_monetary
    return if self.donation_type.nil?
    errors.add(:value, "monetary donation needs value") unless (self.value.to_f > 0) || (self.donation_type.non_monetary)
  end

  def item_if_non_monetary
    return if self.donation_type.nil?
    errors.add(:item, "non-monetary donation needs item") unless (!self.item.blank?) || (!self.donation_type.non_monetary)
  end

  def value_not_negative
    return if self.donation_type.nil?
    errors.add(:value, "invalid value amount") unless (self.value.to_f > 0) || (self.donation_type.non_monetary && !(self.value.to_f < 0))
  end

  private
  def skip_item_check
    @skip_item_check
  end

end
