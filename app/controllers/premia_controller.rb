class PremiaController < ApplicationController

	def index
	end

	def new 
		@premium = Premium.new
	end

	def create 
		@premium = Premium.new(params[:premium])

	    token = params[:premium][:stripe_token]
	    email = params[:premium][:email]
	    description = email + "'s Subscription"

	    begin

	  		charge = Stripe::Charge.create(
	    		:amount => 2000, #CENTS
	    		:currency => "cad",
	    		:card => token,
	    		:description => description
	  		)

		    if @premium.save
		        sign_in @premium
		       	redirect_to root_path
		    else
		    	render 'new'
		    end
		    
	    rescue Stripe::CardError => e
		    @premium.errors.add :base, e.message
		    @premium.stripe_token = nil
		    render :action => :new

 		rescue Stripe::StripeError => e
		    logger.error e.message
		    @premium.errors.add :base, "There was a problem with your credit card"
		    @premium.stripe_token = nil
		    render :action => :new
		end
	end
end
