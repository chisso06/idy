class ApplicationController < ActionController::Base

	before_action :current_user

	def current_user
    unless session[:user_id].nil?
			user = User.find_by(session_token: session[:user_id])
			if user.nil?
				flash[:dangerous] = "ログインし直してください"
				session[:user_id] = nil
				redirect_to login_path
			else
				@current_user = user
			end
		end
	end
end
