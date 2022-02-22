class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:id] = @user.id
      flash[:notice] = "idyへようこそ！"
      redirect_to @user
    else
      render "new"
    end
  end

  def login_form
  end

  def login
    user = User.find_by(email: params[:user][:email])
    if user && user.authenticate(params[:user][:password])
      session[:id] = user.id
      flash[:notice] = "ログインに成功しました"
      redirect_to user
    else
      flash[:notice] = "メールアドレスもしくはパスワードが間違っています"
      render "login_form"
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:notice] = "保存しました"
      redirect_to edit_user_url(@user)
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
