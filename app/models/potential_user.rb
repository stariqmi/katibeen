class PotentialUser < ActiveRecord::Base
  attr_accessible :email, :url, :timezone
  before_save { |puser| puser.email = email.downcase }
  #after_save :sendWelcomeEmail
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :url, presence: true
  validates :timezone, presence: true

  private

  def sendWelcomeEmail 
  	PotentialUserMailer.signup_email(self).deliver
  end


end
