class UsersController < ApplicationController
  before_action :login_user,          only: [:logout, :edit, :update, :edit_email, :edit_email_form, :destroy_form, :destroy, :following, :followers]
  before_action :get_user,            only: [:edit, :update, :edit_email_form, :edit_email, :destroy_form, :destroy, :show, :following, :followers]
  before_action :not_login_user,      only: [:create, :login]
  before_action :not_registered_user, only: [:create]
  before_action :valid_user,          only: [:edit, :update, :edit_email_form, :edit_email, :destroy_form, :destroy, :show]
  before_action :correct_user,        only: [:edit, :update, :edit_email_form, :edit_email, :destroy_form, :destroy]

  # def new
  #   @user = User.new
  # end

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
      redirect_to email_authentication_url(email: @user.new_email)
    else
      flash[:dangerous] = DEFECTIVE_CONTENT_MESSAGE
      redirect_back(fallback_location: root_path)
    end
  end

  # def login_form
  # end

  def login
    if params[:user][:email]
      @user = User.find_by(email: params[:user][:email].downcase)
      @not_activated_user = User.find_by(new_email: params[:user][:email].downcase)
      if @not_activated_user && @not_activated_user.activated?
        @not_activated_user = nil
      end
    end
    # email-presence and correct-password
    if @user && @user.authenticate(params[:user][:password])
      if @user.session_expired? # check valid session
        @user.create_session_token
      end
      session[:user_id] = @user.session_token
      flash[:notice] = WELCOME_MESSAGE
      redirect_to posts_url
    elsif @user.nil? && @not_activated_user && @not_activated_user.authenticate(params[:user][:password]) # not activated
      @not_activated_user.restart_activation
      redirect_to email_authentication_url(email: @not_activated_user.new_email)
    else
      @user = User.new(login_params)
      flash[:dangerous] = WRONG_LOGIN_MESSAGE
      redirect_back(fallback_location: root_path)
    end
  end

  def logout
    @current_user.delete_session_token
    session[:user_id] = nil
    redirect_to root_url
  end

  def edit
  end

  def update
    @user.update(edit_params)
    if params[:user][:image]
      @user.make_image(params[:user][:image])
    end
    if @user.save
      flash[:notice] = SAVE_MESSAGE
      redirect_to user_url(@user)
    else
      flash[:dangerous] = CANNOT_SAVE_MESSAGE
      @posts = Post.where(user_id: @user.id).order(:created_at).reverse
      @like_posts = @user.like_posts
      redirect_back(fallback_location: user_path(@user))
    end
  end

  def edit_email_form
  end

  def edit_email
    if params[:email] && @user.authenticate(params[:password])
      if User.find_by(email: params[:email].downcase) # registered-email
        flash[:dangerous] = REGISTERED_EMAIL_MESSAGE
        render 'edit_email_form'
      else # non registered-email
        @user.new_email = params[:email].downcase
        @user.restart_activation
        redirect_to email_authentication_url(email: @user.new_email)
      end
    else
      flash[:dangerous] = DEFECTIVE_CONTENT_MESSAGE
      render 'edit_email_form'
    end
  end

  def destroy_form
    @reason = ""
  end

  def destroy
    if @user.authenticate(params[:password])
      if @user.image.include?(@user.user_name)
        File.delete("public/user_icons/#{@user.image}")
      end
      @user.destroy
      session[:user_id] = nil
      flash[:notice] = WITHDRAWAL_MESSAGE
      redirect_to root_url
    else
      @reason = params[:reason]
      flash[:dangerous] = WRONG_PASSWORD_MESSAGE
      redirect_back(fallback_location: @user)
    end
  end

  def show
    @posts = Post.where(user_id: @user.id).order(:created_at).reverse
    @like_posts = @user.like_posts
  end

  # def index
  #   @users = User.all
  # end

  # def following
  #   @title = "Following"
  #   @users = @user.following
  #   render 'show_follow'
  # end

  # def followers
  #   @title = "Followers"
  #   @users = @user.followers
  #   render 'show_follow'
  # end

  private

    # params
    def new_params
      params.require(:user).permit(:name, :user_name, :password, :password_confirmation)
    end

    def login_params
      params.require(:user).permit(:email, :password)
    end

    def edit_params
      params.require(:user).permit(:name, :biography)
    end

    # before_actions
    def get_user
      @user =  User.find_by(user_name: params[:id])
      if @user.nil?
        redirect_back(fallback_location: posts_path)
      end
    end

    def login_user
      if @current_user.nil?
        flash[:dangerous] = NEED_LOGIN_MESSAGE
        redirect_to root_path
      end
    end

    def not_login_user
      if @current_user
        flash[:dangerous] = ALREADY_LOGIN_MASSAGE
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
        flash[:dangerous] = REGISTERED_EMAIL_MESSAGE
        redirect_to root_path
      end
    end

    def valid_user
      if @user.nil? || !@user.activated?
        flash[:dangerous] = NOT_EXIST_USER_MESSAGE
        redirect_back(fallback_location: posts_path)
      end
    end

    def correct_user
      if @current_user && @user.id != @current_user.id && !@current_user.admin?
        flash[:dangerous] = NO_AUTHORITY_MESSAGE
        redirect_back(fallback_location: posts_path)
      end
    end
end
