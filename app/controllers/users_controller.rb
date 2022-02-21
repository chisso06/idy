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
      render "new"
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:notice] = "保存しました"
      redirect_to user_url(@user)
    else
      flash[:notice] = "保存に失敗しました"
      render "edit"
    end
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
