class AccountActivationsController < ApplicationController

	before_action :get_user
	# before_action :not_activated_user
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
		if @user.authenticated?(:activation, params[:id])
			if !@user.email
				@user.update(activated: true,
										 activated_at: Time.zone.now)
			end
			@user.update(email: @user.new_email,
									 new_email: nil,
									 activation_digest: nil)
			@user.save
			if session[:user_id].nil?
				session[:user_id] = @user.create_session_token
			end
			flash[:notice] = "メールアドレスの認証が完了しました"
			redirect_to posts_url
		else
			flash[:dangerous] = "認証に失敗しました。認証メールをもう一度送信します。"
			redirect_to send_email_again_url(email: @user.new_email)
			end
		end
	end

	private

		def get_user
			@user = User.find_by(new_email: params[:email].downcase)
		end

		def exist_user
			if @user.nil?
				if User.find_by(email: params[:email].downcase)
					flash[:notice] = "すでに認証が完了しています"
					redirect_to @user
				else
					flash[:dangerous] = "このメールアドレスは登録されていません"
					redirect_to new_user_url
				end
			end
		end

		# メールアドレスを変更したいユーザーが正しいユーザーでログインしているかどうかの確認
		def correct_user
			if @user.email && !@user.authenticated(:session, session[:user_id])
				flash[:dangerous] = "権限がありません"
				redirect_to posts_url
			end
		end

end