class CommentsController < ApplicationController

  before_action :login_user
	before_action :valid_post
	before_action :valid_comment, only: [:update, :destroy]
	before_action :correct_user, only: [:update, :destroy]

	def create
		@comment = Comment.new(
			user_id: session[:user_id],
			post_id: session[:post_id],
			content: comment_params
		)
		if @comment.save
			flash[:notice] = "コメントを投稿しました"
			redirect_back(fallback_location: post_path(session[:post_id]))
		else
			flash[:dangerous] = "コメントを保存できませんでした"
			redirect_back(fallback_location: post_path(session[:post_id]))
		end
	end

	# def update
	# 	comment = Comment.find(params[:id])
	# 	if comment.update(comment_params)
	# 		flash[:notice] = "コメントの内容を更新しました"
	# 		redirect_to post_url(session[:post_id])
	# 	else
	# 		flash[:dangerous] = "コメントの内容を変更できませんでした"
	# 		redirect_to post_url(session[:post_id])
	# 	end
	# end

	def destroy
		comment = Comment.find(params[:id])
		comment.destroy
		flash[:notice] = "コメントを削除しました"
		redirect_to post_url(session[:post_id])
	end

	private
	
		def comment_params
			params.require(:comment).permit(:content)
		end

		def login_user
			if session[:user_id].nil?
				flash[:dangerous] = "ログインしてください"
				redirect_to login_url
			end
		end

		def valid_post
			if session[:post_id].nil?
				flash[:dangerous] = "投稿が存在しません"
				redirect_to posts_url
			elsif Post.find(session[:post_id]).nil?
				flash[:dangerous] = "投稿が存在しません"
				redirect_to posts_url
			end
		end

		def valid_comment
			comment = Comment.find(params[:id])
			if comment.nil?
				flash[:dangerous] = "コメントが存在しません"
				redirect_to post_url(session[:post_id])
			end
		end

		def correct_user
			comment = Comment.find(params[:id])
			if comment.user_id != session[:user_id]
				flash[:dangerous] = "権限がありません"
				redirect_to post_url(session[:post_id])
			end
		end
end
