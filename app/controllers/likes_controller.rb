class LikesController < ApplicationController
	before_action :login_user
	before_action :correct_user, only: :destroy
	before_action :get_post
	before_action :exist_like, only: :destroy

	def create
		@like = Like.new(user_id: @current_user.id, post_id: params[:post_id])
		@like.save
		redirect_back(fallback_location: post_path(@post))
	end

	def destroy
		like = Like.find_by(id: params[:id])
		like.destroy
		redirect_back(fallback_location: post_path(@post))
	end

	def index
		@users = @post.like_users
	end

	private

		def login_user
			if @current_user.nil?
				flash[:dangerous] = NEED_LOGIN_MESSAGE
				redirect_to login_url
			end
		end

		def correct_user
			like = Like.find_by(id: params[:id])
			if @current_user.id != like.user_id && !@current_user.admin?
				flash[:dangerous] = NO_AUTHORITY_MESSAGE
				redirect_back(fallback_location: posts_path)
			end
		end

		def get_post
			@post = Post.find_by(id: params[:post_id])
			if @post.nil?
				flash[:dangerous] = NOT_EXIST_POST_MESSAGE
				redirect_back(fallback_location: posts_path)
			end
		end

		def exist_like
			like = Like.find_by(id: params[:id])
			if like.nil?
				redirect_back(fallback_location: post_path(@post))
			end
		end
end
