class Donation < ActiveRecord::Base
  belongs_to :donation_type
  belongs_to :volunteer
  belongs_to :organization


  attr_accessor :skip_item_check

  scope :non_monetary, -> { joins(:donation_type).where('donation_types.non_monetary = ?', true) }

  validates_date :date_received, allow_blank: false
  validates :donation_type, presence: true
  validate :have_donor
  validate :value_if_monetary
  # validate :item_if_non_monetary, unless: :skip_item_check  Skipping for now
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

  def self.to_csv(report_object)
    if report_object == "organizations"
      attributes = %w(date_received organization_id org_name org_address org_city org_state org_zip org_type value item ref_no don_type anonymous in_honor_of designation notes receipt_sent)
    else
      attributes = %w(date_received volunteer_id vol_name vol_address vol_city vol_state vol_zip value item ref_no don_type anonymous in_honor_of designation notes receipt_sent)
    end
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |donation|
        csv << attributes.map {|attr| donation.send(attr)}
      end
    end
  end

  def org_name
    self.organization.name
  end

  def org_address
    self.organization.address
  end

  def org_city
    self.organization.city
  end

  def org_state
    self.organization.city
  end

  def org_zip
    self.organization.zip
  end

  def org_type
    self.organization.organization_type.name
  end

  def vol_name
    self.volunteer.name
  end

  def vol_address
    self.volunteer.address
  end

  def vol_city
    self.volunteer.city
  end

  def vol_state
    self.volunteer.state
  end

  def vol_zip
    self.volunteer.zip
  end

  def don_type
    self.donation_type.name
  end

  private
  def skip_item_check
    @skip_item_check
  end

end
