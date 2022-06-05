class AccountActivationsController < ApplicationController

	before_action :exist_user
	before_action :not_activated_user

	def email_authentication
		@user = User.find_by(email: params[:email])
	end

	def send_email_again
		user = User.find_by(email: params[:email])
		user.create_activation_token_and_digest("")
		# user.create_activation_token_and_digest("send_email_again") #test
		user.save
		user.send_activation_email
		flash[:notice] = "認証メールを送信しました"
		redirect_to email_authentication_url(email: user.email)
	end

	def edit
		user = User.find_by(email: params[:email])
		if user.authenticated?(:activation, params[:id])
			user.update(activated: true,
									activated_at: Time.zone.now,
									activation_digest: nil)
			session[:user_id] = user.reset_session_token
			flash[:notice] = "idyにようこそ！"
			redirect_to posts_url
		else
			flash[:dangerous] = "認証に失敗しました。認証メールをもう一度送信します。"
			redirect_to send_email_again_path(email: params[:email])
		end
	end
end

private

	def exist_user
		user = User.find_by(email: params[:email])
		if user.nil?
			flash[:dangerous] = "このメールアドレスは登録されていません。"
			redirect_to new_user_path
		end
	end

	def not_activated_user
		user = User.find_by(email: params[:email])
		if user.activated
			flash[:notice] = "すでに認証が完了しています"
			if @current_user
				redirect_to posts_url
			else
				redirect_to login_url
			end
		end
	end
