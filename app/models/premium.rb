class Premium < ActiveRecord::Base
  attr_accessible :email, :password, :remember_token, :username
  has_secure_password

  def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Premium.exists?(column => self[column])
  end

end
