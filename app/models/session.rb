class Session < ActiveRecord::Base
  attr_accessible :email
  has_secure_password

  before_save { self.email.downcase! }
  
  validates :password, presence: true , length: { minimum: 5, maximum: 20 }

  validates :password_confirmation, presence: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness:  { case_sensitive: false }
end