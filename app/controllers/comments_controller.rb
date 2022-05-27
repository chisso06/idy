class CommentsController < ApplicationController

  before_action :login_user
	before_action :valid_post
	before_action :valid_comment, only: [:update, :destroy]
	before_action :correct_user, only: [:update, :destroy]

	def create
		@comment = Comment.new(comment_params)
		@comment.user_id = @current_user.id
		@comment.post_id = params[:post_id]
		if @comment.save
			flash[:notice] = "コメントを投稿しました"
			redirect_back(fallback_location: post_path(params[:post_id]))
		else
			flash[:dangerous] = "コメントを保存できませんでした"
			redirect_back(fallback_location: post_path(params[:post_id]))
		end
	end

	# def update
	# 	comment = Comment.find(params[:id])
	# 	if comment.update(comment_params)
	# 		flash[:notice] = "コメントの内容を更新しました"
	# 		redirect_to post_url(params[:post_id])
	# 	else
	# 		flash[:dangerous] = "コメントの内容を変更できませんでした"
	# 		redirect_to post_url(params[:post_id])
	# 	end
	# end

	def destroy
		comment = Comment.find_by(id: params[:id])
		comment.destroy
		flash[:notice] = "コメントを削除しました"
		redirect_to post_url(params[:post_id])
	end

	private
	
		def comment_params
			params.permit(:content)
		end

		def login_user
			if @current_user.nil?
				flash[:dangerous] = "ログインしてください"
				redirect_to login_url
			end
		end

		def valid_post
			if Post.find_by(id: params[:post_id]).nil?
				flash[:dangerous] = "投稿が存在しません"
				redirect_to posts_url
			end
		end

		def valid_comment
			comment = Comment.find_by(id: params[:id])
			if comment.nil?
				flash[:dangerous] = "コメントが存在しません"
				redirect_to post_url(params[:post_id])
			end
		end

		def correct_user
			comment = Comment.find_by(id: params[:id])
			if comment.user_id != @current_user.id && @current_user.admin == "0"
				flash[:dangerous] = "権限がありません"
				redirect_to post_url(params[:post_id])
			end
		end
end
