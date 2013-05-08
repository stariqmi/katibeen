class Premium < ActiveRecord::Base
  attr_accessible :email, :password, :remember_token, :username, :password_confirmation
  has_secure_password

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_token = self.password_reset_token.to(6)
    self.password_reset_sent_at = Time.zone.now
    save!
    PremiumMailer.password_reset(self).deliver
  end

  def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Premium.exists?(column => self[column])
  end

end
