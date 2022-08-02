class AccountActivationsController < ApplicationController

	before_action :get_user
	before_action :exist_user
	before_action :correct_user, only: [:email_authentication, :send_email_again]

	def email_authentication
	end

	def send_email_again
		@user.restart_activation
		flash[:notice] = SEND_EMAIL_MESSAGE
		redirect_to email_authentication_url(email: @user.new_email)
	end

	def edit
		if @user.authenticated?(:activation, params[:id]) # token が正しい状態
			if !@user.activated? # メールアドレスの変更ではなく新規登録からの場合
				@user.update(activated: true,
										 activated_at: Time.zone.now)
			end
			@user.update(email: @user.new_email,
									 new_email: nil,
									 activation_digest: nil)
			@user.save
			# ログイン
			flash[:notice] = COMPLETE_EMAIL_AUTHENTICATION_MESSAGE
			session[:user_id] = nil
			redirect_to root_url
		else
			flash[:dangerous] = FAIL_AUTHENTICATE_MESSAGE
			redirect_to send_email_again_url(email: @user.new_email)
		end
	end

	private

		def get_user
			if params[:email]
				@user = User.find_by(new_email: params[:email].downcase)
			else
				flash[:dangerous] = UNEXPECTED_ERROR_MESSAGE
				redirect_back(fallback_location: posts_url)
			end
		end

		def exist_user
			if @user.nil?
				@user = User.find_by(email: params[:email].downcase)
				if @user
					if @user.activated?
						flash[:notice] = ALREADY_AUTHENTICATED_MASSAGE
						if @current_user
							redirect_to posts_url
						else
							redirect_to root_url
						end
					else
						flash[:dangerous] = UNEXPECTED_ERROR_MESSAGE
						redirect_back(fallback_location: posts_url)
					end
				else
					flash[:dangerous] = NOT_REGISTERED_EMAIL_MESSAGE
					redirect_back(fallback_location: posts_url)
				end
			end
		end

		def correct_user
			if (@current_user && @user.id != @current_user.id) && !@current_user.admin?
				flash[:dangerous] = NO_AUTHORITY_MESSAGE
				redirect_back(fallback_location: posts_url)
			end
		end
end