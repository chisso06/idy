class LikesController < ApplicationController
	before_action :login_user
	before_action :valid_post

	def create
		if Like.find_by(user_id: @current_user.id, post_id: params[:post_id]).nil?
			@like = Like.new(user_id: @current_user.id, post_id: params[:post_id])
			@like.save
		end
		redirect_back(fallback_location: post_path(params[:post_id]))
	end

	def destroy
		like = Like.find_by(params[:id])
		unless like.nil?
			like.destroy
		end
		redirect_back(fallback_location: post_path(params[:post_id]))
	end

	def index
		@post = Post.find_by(id: params[:post_id])
		likes = Like.where(post_id: params[:post_id])
		@users = []
		likes.each do |like|
			@users.push(User.find_by(id: like.user_id))
		end
	end

	private

		def login_user
			if @current_user.nil?
				flash[:dangerous] = "ログインしてください"
				redirect_to login_url
			end
		end

		def valid_post
			if Post.find_by(id: params[:post_id]).nil? && !@current_user.admin?
				flash[:dangerous] = "投稿が存在しません"
				redirect_to posts_url
			end
		end
end
