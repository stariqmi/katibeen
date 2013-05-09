class AddStripeTokenToPremia < ActiveRecord::Migration
  def change
    add_column :premia, :stripe_token, :string
    add_column :premia, :last_4_digits, :string
  end
end
