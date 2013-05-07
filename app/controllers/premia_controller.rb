class PremiaController < ApplicationController
http_basic_authenticate_with :name => "katibean", :password => "What'sup!"

	def index
	end
	def new 
		@premium = Premium.new
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
