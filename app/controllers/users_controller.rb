class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "idyへようこそ！"
      redirect_to root_url
    else
      flash[:notice] = "ログインに失敗しました"
      render "new"
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def show
  end

  def index
  end

  private

    def user_params
      params.require(:user).permit(:name, :user_name, :email, :password, :password_confirmation)
    end
end
