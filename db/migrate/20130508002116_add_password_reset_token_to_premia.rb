class AddPasswordResetTokenToPremia < ActiveRecord::Migration
  def change
    add_column :premia, :password_reset_token, :string
    add_column :premia, :password_reset_sent_at, :datetime
  end
end
