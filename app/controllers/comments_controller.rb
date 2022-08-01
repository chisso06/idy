class CommentsController < ApplicationController

  before_action :login_user
	before_action :get_post
	before_action :get_comment, only: :destroy
	before_action :correct_user, only: :destroy

	def create
		@comment = Comment.new(comment_params)
		@comment.user_id = @current_user.id
		@comment.post_id = @post.id
		if @comment.save
			redirect_back(fallback_location: post_path(@post.id))
		else
			flash[:dangerous] = CANNOT_SAVE_MESSAGE
			render 'posts/show'
		end
	end

	# def update
	# 	comment = Comment.find(params[:id])
	# 	if comment.update(comment_params)
	# 		flash[:notice] = "コメントの内容を更新しました"
	# 		redirect_to post_url(@post.id)
	# 	else
	# 		flash[:dangerous] = "コメントの内容を変更できませんでした"
	# 		redirect_to post_url(@post.id)
	# 	end
	# end

	def destroy
		@comment.destroy
		redirect_back(fallback_location: post_path(@post.id))
	end

	private

		def comment_params
			params.permit(:content)
		end

		def login_user
			if @current_user.nil?
				flash[:dangerous] = NEED_LOGIN_MESSAGE
				redirect_to root_url
			end
		end

		def get_post
      @post = Post.find_by(id: params[:post_id])
			if @post.nil?
				flash[:dangerous] = NOT_EXIST_POST_MESSAGE
				redirect_to posts_url
			end
		end

		def get_comment
			@comment = Comment.find_by(id: params[:id])
			if @comment.nil?
				flash[:dangerous] = UNEXPECTED_ERROR_MESSAGE
				redirect_back(fallback_location: post_url(@post))
			end
		end

		def correct_user
			if @comment.user_id != @current_user.id && !@current_user.admin?
				flash[:dangerous] = NO_AUTHORITY_MESSAGE
				redirect_back(fallback_location: post_url(@post))
			end
		end
end
