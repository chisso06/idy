class UsersController < ApplicationController
  before_action :login_user,          only: [:logout, :edit, :update, :destroy_form, :destroy, :edit_email, :edit_email_form, :following, :followers]
  before_action :not_login_user,      only: [:new, :create, :login_form, :login]
  before_action :not_registered_user, only: [:create]
  before_action :valid_user,          only: [:edit, :update, :edit_email_form, :edit_email, :destroy_form, :destroy, :show, :following, :followers]
  before_action :correct_user,        only: [:edit, :update, :edit_email_form, :edit_email, :destroy_form, :destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(new_params)
    if params[:user][:email] && params[:user][:user_name]
      @user.new_email = params[:user][:email].downcase
      @user.user_name = params[:user][:user_name].downcase
    end
    @user.image = "admin.png"
    if @user.save
      @user.create_activation_token_and_digest
      @user.send_activation_email
      flash[:notice] = "メールアドレスの認証を行います。認証メールを送信しました"
      redirect_to email_authentication_url(email: @user.new_email)
    else
      flash[:dangerous] = "内容に不備があります"
      render "new"
    end
  end

  def login_form
  end

  def login
    if params[:email]
      @user = User.find_by(email: params[:email].downcase)
      @not_activated_user = User.find_by(new_email: params[:email].downcase)
      if @not_activated_user && @not_activated_user.activated?
        @not_activated_user = nil
      end
    end
    # email-presence and correct-password
    if @user && @user.authenticate(params[:password])
      if @user.session_expired? # check valid session
        @user.create_session_token
      end
      session[:user_id] = @user.session_token
      flash[:notice] = "idyにようこそ！"
      redirect_to posts_url
    elsif @user.nil? && @not_activated_user && @not_activated_user.authenticate(params[:password]) # not activated
      flash[:dangerous] = "メールアドレスの認証がまだです。認証メールを送信しました。"
      @user.restart_activation
      redirect_to email_authentication_url(email: @user.new_email)
    else
      flash[:dangerous] = "メールアドレスもしくはパスワードが間違っています"
      render "login_form"
    end
  end

  def logout
    @current_user.delete_session_token
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
    if params[:user][:image]
      @user.make_image(params[:user][:image])
    end
    if @user.save
      flash[:notice] = "保存しました"
      redirect_to @user
    else
      flash[:dangerous] = "保存に失敗しました"
      render "edit"
    end
  end

  def edit_email_form
    @user = User.find_by(user_name: params[:id])
  end

  def edit_email
    @user = User.find_by(user_name: params[:id])
    if params[:email] && @user.authenticate(params[:password])
      if @user.email == params[:email].downcase # registered-email
        flash[:dangerous] = "このメールアドレスはすでに登録されています"
        render 'edit_email_form'
      else # non registered-email
        @user.new_email = params[:email].downcase
        @user.restart_activation
        flash[:notice] = "認証メールを送信しました"
        redirect_to email_authentication_url(email: @user.new_email)
      end
    else
      flash[:dangerous] = "内容に不備があります"
      render "edit_email_form"
    end
  end

  def destroy_form
    @user = User.find_by(user_name: params[:id])
    @reason = ""
  end

  def destroy
    @user = User.find_by(user_name: params[:id])
    if @user.authenticate(params[:password])
      if @user.image.include?(@user.user_name)
        File.delete("public/user_icons/#{@user.image}")
      end
      @user.destroy
      session[:user_id] = nil
      flash[:notice] = "退会が完了しました"
      redirect_to root_url
    else
      @reason = params[:reason]
      flash[:dangerous] = "パスワードが違います"
      render "destroy_form"
    end
  end

  def show
    @user = User.find_by(user_name: params[:id])
    @posts = Post.where(user_id: @user.id)
    @likes = Like.where(user_id: @user.id)
  end

  def index
    @users = User.all
  end

  def following
    @title = "Following"
    @user = User.find_by(user_name: params[:id])
    @users = @user.following
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find_by(user_name: params[:id])
    @users = @user.followers
    render 'show_follow'
  end

  private

    # params
    def new_params
      params.require(:user).permit(:name, :user_name, :password, :password_confirmation)
    end

    def edit_params
      params.require(:user).permit(:name, :biography)
    end

    # before_actions
    def login_user
      if @current_user.nil?
        flash[:dangerous] = "ログインしてください"
        redirect_to login_path
      end
    end

    def not_login_user
      if @current_user
        redirect_to posts_path
      end
    end

    def not_registered_user
      if params[:user][:email]
        @registered_user = User.find_by(email: params[:user][:email].downcase)
        if @registered_user.nil?
          @registered_user = User.find_by(new_email: params[:user][:email].downcase)
        end
      end
      if @registered_user
        flash[:dangerous] = "このメールアドレスは登録済みです。ログインしてください。"
        redirect_to login_path
      end
    end

    def valid_user
      user =  User.find_by(user_name: params[:id])
      if user.nil? || !user.activated?
        flash[:dangerous] = "このユーザーは存在しません"
        redirect_to posts_path
      end
    end

    def correct_user
      user = User.find_by(user_name: params[:id])
      if @current_user && user.id != @current_user.id && !@current_user.admin?
        flash[:dangerous] = "権限がありません"
        redirect_to posts_path
      end
    end
end
