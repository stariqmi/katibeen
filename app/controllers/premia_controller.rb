class PremiaController < ApplicationController

	def index
	end

	def new 
		@premium = Premium.new
		@user = current_user
	end

	def create 
		@premium = Premium.new(params[:premium])
	    if @premium.save
	        sign_in @premium
	       	redirect_to root_path
	    else
	    	render 'new'
	    end
	end

end
