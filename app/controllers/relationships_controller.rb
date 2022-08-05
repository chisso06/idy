class RelationshipsController < ApplicationController

	before_action :get_user

	def create
		@current_user.follow(@user)
		redirect_to @user
	end

	def destroy
		# user = Relationship.find_by(id: @user.id).followed
		@current_user.unfollow(@user)
		redirect_to @user
	end

	private
		def get_user
			@user = User.find_by(user_name: params[:id])
			if @user.nil?
				flash[:notice] = NOT_EXIST_USER_MESSAGE
				redirect_back(fallback_location: posts_path)
			end
		end
end
