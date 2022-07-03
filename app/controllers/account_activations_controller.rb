class AccountActivationsController < ApplicationController

	before_action :get_user
	before_action :exist_user
	before_action :correct_user, only: [:email_authentication, :send_email_again]

	def email_authentication
	end

	def send_email_again
		@user.restart_activation
		flash[:notice] = "認証メールを送信しました"
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
			flash[:notice] = "メールアドレスの認証が完了しました"
			if session[:user_id].nil?
				redirect_to login_url
			else
				redirect_to posts_url
			end
		else
			flash[:dangerous] = "認証に失敗しました。認証メールをもう一度送信します。"
			redirect_to send_email_again_url(email: @user.new_email)
		end
	end

	private

		def get_user
			if params[:email]
				@user = User.find_by(new_email: params[:email].downcase)
			else
				flash[:dangerous] = "問題が発生しました。やり直してください。"
				redirect_back fallback_location: posts_url
			end
		end

		def exist_user
			if @user.nil?
				@user = User.find_by(email: params[:email].downcase)
				if @user
					if @user.activated?
						flash[:notice] = "すでに認証が完了しています"
						if @current_user
							redirect_to posts_url
						else
							redirect_to login_url
						end
					else
						flash[:dangerous] = "予期せぬエラーが発生しました"
						redirect_back fallback_location: posts_url
					end
				else
					flash[:dangerous] = "このメールアドレスは登録されていません"
					redirect_back fallback_location: posts_url
				end
			end
		end

		def correct_user
			if (@current_user && @user.id != @current_user.id) && !@current_user.admin?
				flash[:dangerous] = "権限がありません"
				redirect_back fallback_location: posts_url
			end
		end
end