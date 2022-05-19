class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
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
      session[:user_id] = user.id
      flash[:notice] = "ログインに成功しました"
      redirect_to user
    else
      flash[:dangerous] = "メールアドレスもしくはパスワードが間違っています"
      render "login_form"
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_url
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
      flash[:dangerous] = "保存に失敗しました"
      render "edit"
    end
  end

  def destroy
    User.find_by(params[:id]).destroy
    session[:user_id] = nil
    redirect_to root_url
  end

  def show
    @user = User.find(params[:id])
    @posts = Post.where(user_id: params[:id])
    @likes = Like.where(user_id: params[:id])
  end

  def index
  end

  private

    def user_params
      params.require(:user).permit(:name, :user_name, :email, :password, :password_confirmation)
    end
end
