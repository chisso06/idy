class LikesController < ApplicationController
	before_action :login_user
	before_action :valid_post

	def create
		if Like.find_by(user_id: session[:user_id], post_id: session[:post_id]).nil?
			@like = Like.new(user_id: session[:user_id], post_id: session[:post_id])
			@like.save
		end
		redirect_back(fallback_location: post_path(session[:post_id]))
	end

	def destroy
		like = Like.find_by(user_id: session[:user_id], post_id: session[:post_id])
		unless like.nil?
			like.destroy
		end
		redirect_back(fallback_location: post_path(session[:post_id]))
	end

	def index
		@post = Post.find(session[:post_id])
		likes = Like.where(post_id: session[:post_id])
		@users = []
		likes.each do |like|
			@users.push(User.find(like.user_id))
		end
	end

	private

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
end
