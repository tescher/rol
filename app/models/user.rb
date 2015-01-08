class User < ActiveRecord::Base

  before_save { self.email = email.downcase }
  validates :name, presence: true
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: MIN_PASSWORD_LENGTH }


end
