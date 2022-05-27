class UsersController < ApplicationController
  before_action :login_user, only: [:logout, :edit, :update, :show]
  before_action :valid_user, only: :show
  before_action :correct_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    require 'securerandom'
    @user = User.new(new_params)
    @user.hashed_id = to_hash_id
    @user.image = "admin.png"
    if @user.save
      session[:user_id] = @user.hashed_id
      flash[:notice] = "idyへようこそ！"
      redirect_to posts_path
    else
      flash[:dangerous] = "内容に不備があります"
      render "new"
    end
  end

  def login_form
  end

  def login
    user = User.find_by(user_name: params[:user_name])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.hashed_id
      flash[:notice] = "ログインに成功しました"
      redirect_to posts_path
    else
      flash[:dangerous] = "ユーザー名もしくはパスワードが間違っています"
      render "login_form"
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "ログアウトしました"
    redirect_to root_url
  end

  def edit
    @user = User.find_by(user_name: params[:id])
  end

  def update
    @user = User.find_by(user_name: params[:id])
    @user.update(edit_params)
    if @user.save
      flash[:notice] = "保存しました"
      redirect_to @user
    else
      flash[:dangerous] = "保存に失敗しました"
      render "edit"
    end
  end

  def show
    @user = User.find_by(user_name: params[:id])
    @posts = Post.where(user_id: @user.id)
    @likes = Like.where(user_id: @user.id)
  end

  private

    def new_params
      params.require(:user).permit(:name, :user_name, :email, :password)
    end

    def edit_params
      params.require(:user).permit(:name, :biography)
    end

    def to_hash_id
      hashed_id = SecureRandom.alphanumeric(5)
      while (User.find_by(hashed_id: @user.hashed_id))
        hashed_id = SecureRandom.alphanumeric(5)
      end
      return hashed_id
    end

    def login_user
      if @current_user.nil?
        flash[:dangerous] = "ログインしてください"
        redirect_to login_path
      end
    end

    def valid_user
      if User.find_by(user_name: params[:id]).nil?
        flash[:dangerous] = "このユーザーは存在しません"
        redirect_to posts_path
      end
    end

    def correct_user
      user = User.find_by(user_name: params[:id])
      if user.id != @current_user.id && @current_user.admin == "0"
        flash[:dangerous] = "権限がありません"
        redirect_to posts_path
      end
    end
end
