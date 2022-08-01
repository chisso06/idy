class PasswordResetsController < ApplicationController

  before_action :get_user,         only: [:create, :edit, :update]
  before_action :exist_user,       only: [:create, :edit, :update]
	before_action :activated_user,   only: [:create, :edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  before_action :correct_token,    only: [:edit, :update]

  def new
  end

  def create
    @user.create_reset_token_and_digest
    @user.reset_sent_at = Time.zone.now
    @user.save
    @user.send_password_reset_email
    flash[:notice] = SEND_PASSWORD_RESET_EMAIL_MESSAGE
    redirect_to root_url
  end

  def edit
  end

  def update
    if params[:user][:password].nil?
      flash[:dangerous] = DEFECTIVE_CONTENT_MESSAGE
      render 'edit'
    elsif @user.update(user_params)
      flash[:notice] = UPDATE_PASSWORD_MESSAGE_MESSAGE
      @user.reset_digest = nil
      @user.reset_sent_at = nil
      redirect_to root_url
    else
      flash[:dangerous] = DEFECTIVE_CONTENT_MESSAGE
      render 'edit'
    end
  end

  private

    # params
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # before_action

    def get_user
      if params[:email]
        @user = User.find_by(email: params[:email].downcase)
        if @user.nil?
          @user = User.find_by(new_email: params[:email].downcase)
        end
      else
        flash[:dangerous] = DEFECTIVE_CONTENT_MESSAGE
        render 'edit'
      end
    end

    def exist_user
      if @user.nil?
        flash[:dangerous] = NOT_REGISTERED_EMAIL_MESSAGE
        redirect_to new_password_reset_url
      end
    end

    def activated_user
      if !@user.activated?
        debugger
        @user.delete_session_token
        session[:user_id] = nil
        @user.restart_activation
        flash[:dangerous] = EMAIL_AUTHENTICATION_MESSAGE
        redirect_to email_authentication_url(email: @user.email)
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:dangerous] = FAIL_AUTHENTICATE_MESSAGE
        redirect_to new_password_reset_url
      end
    end

    def correct_token
      if !@user.authenticated?(:reset, params[:id])
        flash[:dangerous] = FAIL_AUTHENTICATE_MESSAGE
        redirect_to new_password_reset_url
      end
    end
end
