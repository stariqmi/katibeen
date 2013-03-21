class User < ActiveRecord::Base
  attr_accessible :email, :timezone, :url
  before_save { |user| user.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :timezone, presence: true
  validates :url, presence: true, uniqueness: true
end
