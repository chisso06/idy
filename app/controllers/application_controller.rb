class ApplicationController < ActionController::Base

	before_action :current_user

	def current_user
    if session[:user_id]
			user = User.find_by(session_token: session[:user_id])
			if user.nil? || user.session_expired?
				flash[:dangerous] = "ログインし直してください"
				session[:user_id] = nil
				redirect_to login_path
			else
				@current_user = user
			end
		end
	end
end
