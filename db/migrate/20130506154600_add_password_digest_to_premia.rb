class AddPasswordDigestToPremia < ActiveRecord::Migration
  def change
    add_column :premia, :password_digest, :string
  end
end
