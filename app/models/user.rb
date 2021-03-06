class User < ActiveRecord::Base

  attr_accessible :email, :timezone, :url, :average, :day, :registered

  before_save { |user| user.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :timezone, presence: true
  validates :url, presence: true, uniqueness: true
  has_many :outgoing_day_prayers, :dependent => :destroy

  def sendWelcomeEmail
  	if !self.registered?
    	UserMailer.confirmation_email(self).deliver
  	end
  end

  def sendRelaunch
    if !self.registered?
      UserMailer.sendRelaunch(self).deliver
    end
  end

  def sendUnsubscribe
    UserMailer.unsubscribe(self).deliver
  end

  def sendError
    UserMailer.error(self).deliver
  end

  def get_prayers
    prayers = OutgoingDayPrayer.where(:url => self.url, :status => "responded")
    return prayers
  end
end
