class AddPasswordConfirmationToPremiaAgain < ActiveRecord::Migration
  def change
    add_column :premia, :password_confirmation, :string
  end
end
