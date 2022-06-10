class UsersController < ApplicationController
  before_action :login_user,     only: [:logout, :edit, :update, :destroy_form, :destroy, :edit_email, :edit_email_form]
  before_action :not_login_user, only: [:new, :create, :login_form, :login]
  before_action :activated_user, only: [:edit, :update, :edit_email, :edit_email_form]
  before_action :valid_user,     only: [:edit, :update, :edit_email_form, :edit_email, :destroy_form, :destroy, :show]
  before_action :correct_user,   only: [:edit, :update, :edit_email_form, :edit_email, :destroy_form, :destroy]

  def new
    @user = User.new
  end

  def create
    if User.find_by(email: params[:user][:email].downcase)
      flash[:dangerous] = "このメールアドレスは登録済みです。ログインしてください。"
      redirect_to login_path
    elsif User.find_by(new_email: params[:user][:email].downcase)
      flash[:dangerous] = "このメールアドレスは登録済みです。ログインしてください。"
      redirect_to login_path
    else
      @user = User.new(new_params)
      @user.new_email = params[:user][:email].downcase
      @user.image = "admin.png"
      if @user.save
        @user.create_activation_token_and_digest
        @user.send_activation_email
        flash[:notice] = "認証メールを送信しました"
        redirect_to email_authentication_url(email: @user.new_email)
      else
        flash[:dangerous] = "内容に不備があります"
        render "new"
      end
    end
  end

  def login_form
  end

  def login
    get_user
    if @user && @user.authenticate(params[:password])
      if @user.session_expired?
        @user.create_session_token
      end
      session[:user_id] = @user.session_token
      flash[:notice] = "idyにようこそ！"
      redirect_to posts_url
    else
      flash[:dangerous] = "ユーザー名/メールアドレスもしくはパスワードが間違っています"
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
    if @user.email == params[:email].downcase || @user.new_email == params[:email].downcase
      flash[:dangerous] = "このメールアドレスはすでに登録されています"
      render 'edit_email_form'
    else
      @user.new_email = params[:email].downcase
      if @user.authenticate(params[:password]) && @user.save
        @user.restart_activation
        flash[:notice] = "認証メールを送信しました"
        redirect_to email_authentication_url(email: @user.new_email)
      else
        flash[:dangerous] = "内容に不備があります"
        render "edit_email_form"
      end
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

  private

    # params
    def new_params
      params.require(:user).permit(:name, :user_name, :password)
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

    def activated_user #testまだ
      user = User.find_by(user_name: params[:id])
      if !user.activated?
        user.delete_session_token
        session[:user_id] = nil
        user.restart_activation
        flash[:dangerous] = "メールアドレスの認証がまだです。認証メールを送信しました。"
        redirect_to email_authentication_url(email: user.new_email)
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
      if user.id != @current_user.id && !@current_user.admin?
        flash[:dangerous] = "権限がありません"
        redirect_to posts_path
      end
    end

    def get_user # for login
      @user = User.find_by(user_name: params[:user_info].downcase)
      if @user.nil?
        @user = User.find_by(email: params[:user_info].downcase)
        if @user.nil?
          @user = User.find_by(new_email: params[:user_info].downcase)
          if !@user.nil?
            flash[:dangerous] = "メールアドレスの認証がまだです。認証メールを送信しました。"
            @user.restart_activation
            redirect_to email_authentication_url(email: @user.new_email)
          end
        end
      end
    end
end
