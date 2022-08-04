class ApplicationController < ActionController::Base

	before_action :current_user
	before_action :set_search

	UNEXPECTED_ERROR_MESSAGE		 = "予期せぬエラーが発生しました"
  NO_AUTHORITY_MESSAGE				 = "権限がありません"
  SAVE_MESSAGE								 = "保存しました"
  CANNOT_SAVE_MESSAGE					 = "保存に失敗しました"
  NEED_LOGIN_MESSAGE					 = "ログインしてください"
  DEFECTIVE_CONTENT_MESSAGE		 = "内容に不備があります"
	NOT_REGISTERED_EMAIL_MESSAGE = "このメールアドレスは登録されていません"
	FAIL_AUTHENTICATE_MESSAGE		 = "認証に失敗しました。"
  NOT_EXIST_USER_MESSAGE			 = "このユーザーは存在しません"
	NOT_EXIST_POST_MESSAGE			 = "この投稿は存在しません"

	# application
	NEED_LOGIN_AGAIN_MESSAGE = "ログインし直してください"
	SEND_EMAIL_MESSAGE			 = "認証メールを送信しました"

	# users
  WRONG_LOGIN_MESSAGE			 = "メールアドレスもしくはパスワードが間違っています"
  WRONG_PASSWORD_MESSAGE	 = "パスワードが間違っています"
  WELCOME_MESSAGE					 = "idyへようこそ！"
  REGISTERED_EMAIL_MESSAGE = "このメールアドレスはすでに登録されています"
  WITHDRAWAL_MESSAGE			 = "アカウントを削除しました"
  ALREADY_LOGIN_MASSAGE		 = "すでにログインしています"

	# account_activations
	COMPLETE_EMAIL_AUTHENTICATION_MESSAGE = "メールアドレスの認証が完了しました"
	ALREADY_AUTHENTICATED_MASSAGE					= "すでに認証が完了しています"

	# password_resets
	SEND_PASSWORD_RESET_EMAIL_MESSAGE = "パスワード再設定メールを送信しました"
	UPDATE_PASSWORD_MESSAGE_MESSAGE		= "パスワードを更新しました"

	# posts
	SUCCESSFUL_POST_MESSAGE = "アイデアを投稿しました！"
	DESTROY_POST_MESSAGE		= "投稿を削除しました"

	def current_user
    if session[:user_id]
			user = User.find_by(session_token: session[:user_id])
			if user.nil? || user.session_expired?
				flash[:dangerous] = NEED_LOGIN_AGAIN_MESSAGE
				session[:user_id] = nil
				redirect_to root_url
			else
				@current_user = user
			end
		else
			@current_user = nil
		end
	end

	def set_search
		if @current_user
			@q = Post.ransack(params[:q])
			@search_posts = @q.result(distinct: true)
			@search_following_posts = following_posts(@q.result(distinct: true))
		end
  end

	private

		def following_posts(posts)
			following_posts = []
			posts.each do |p|
				if @current_user == p.user || @current_user.following?(p.user)
					following_posts.push(p)
				end
			end
			return following_posts
		end
end
