class PasswordResetsController < ApplicationController

  before_action :exist_user, only: [:create, :edit, :update]
	before_action :activated_user, only: [:create, :edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  before_action :correct_token, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:email].downcase)
    @user.create_reset_token_and_digest
    @user.reset_sent_at = Time.zone.now
    @user.save
    @user.send_password_reset_email
    flash[:notice] = "パスワード再設定メールを送信しました"
    redirect_to new_password_reset_url
  end

  def edit
    @user = User.find_by(email: params[:email].downcase)
  end

  def update
    @user = User.find_by(email: params[:email].downcase)
    if params[:user][:password].empty?
      debugger
      flash[:dangerous] = "パスワードを入力してください"
      render 'edit'
    elsif @user.update(user_params)
      flash[:notice] = "パスワードを更新しました"
      @user.reset_digest = nil
      @user.reset_sent_at = nil
      redirect_to login_url
    else
      debugger
      flash[:dangerous] = "内容に不備があります"
      render 'edit'
    end
  end

  private

    # params
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # before_action
    def exist_user
      user = User.find_by(email: params[:email].downcase)
      if user.nil?
        debugger
        flash[:dangerous] = "このメールアドレスは登録されていません"
        redirect_to new_password_reset_url
      end
    end

    def activated_user
      user = User.find_by(email: params[:email].downcase)
      if !user.activated?
        debugger
        user.reset_session_token
        session[:user_id] = nil
        user.restart_activation
        flash[:dangerous] = "メールアドレスの認証がまだです。認証メールを送信しました。"
        redirect_to email_authentication_url(email: user.email)
      end
    end

    def check_expiration
      user = User.find_by(email: params[:email].downcase)
      if user.password_reset_expired?
        debugger
        flash[:dangerous] = "認証に失敗しました。はじめからやり直してください。"
        redirect_to new_password_reset_url
      end
    end

    def correct_token
      user = User.find_by(email: params[:email].downcase)
      if !user.authenticated?(:reset, params[:id])
        debugger
        flash[:dangerous] = "認証に失敗しました。はじめからやり直してください。"
        redirect_to login_url
      end  
    end
end
