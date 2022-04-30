class LikesController < ApplicationController
	before_action :login_user
	before_action :valid_post

	def create
		if Like.find_by(user_id: session[:id], post_id: params[:post_id]).nil?
			@like = Like.new(user_id: session[:id], post_id: params[:post_id])
			@like.save
		end
		redirect_back(fallback_location: post_path(params[:post_id]))
	end

	def destroy
		Like.find_by(user_id: session[:id], post_id: params[:post_id]).destroy
		redirect_back(fallback_location: post_path(params[:post_id]))
	end

	def index
		@users = User.where(post_id: params[:post_id])
	end

	private

		def login_user
			if session[:id].nil?
				flash[:notice] = "ログインしてください"
				redirect_to login_url
			end
		end

		def valid_post
			if Post.find_by(id: params[:post_id]).nil?
				redirect_to posts_url
			end
		end
end
