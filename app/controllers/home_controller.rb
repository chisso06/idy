class HomeController < ApplicationController
  before_action :login_user, only: :top

  def top
  end

  private
    def login_user
      if @current_user
        redirect_to posts_url
      end
    end
end
