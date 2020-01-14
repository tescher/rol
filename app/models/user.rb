class User < ApplicationRecord
  attr_accessor :remember_token

  has_many :contacts, dependent: :restrict_with_exception
  has_many :last_edit_contacts, class_name: "Contact", foreign_key: :last_edit_user_id, dependent: :restrict_with_exception

  before_save {
    self.email = email.downcase
  }
  validates :name, presence: true
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  has_secure_password
  # TODO: Hard coding this for now. Will have to figure out how to properly dynamiccally get this from the database.
  # validates :password, length: { minimum: Utilities::Utilities.system_setting(:min_password_length) }, allow_blank: true
  validates :password, length: { minimum: 6 }, allow_blank: true
  # validates :password, length: { minimum: Utilities::Utilities.system_setting(:min_password_length) }, allow_blank: true
  validate :only_one_donation_security_type

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def donations_allowed
    self.admin || self.all_donations || self.non_monetary_donations
  end

  def monetary
    self.admin || self.all_donations
  end

  def non_monetary
    !self.admin && !self.all_donations && self.non_monetary_donations
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  private
  def only_one_donation_security_type
    errors.add(:all_donations, "Can't select both donation security settings") unless !(self.all_donations && self.non_monetary_donations)
  end


end
