class PasswordResetsController < ApplicationController

  before_action :get_user,         except: [:new]
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
    flash[:notice] = "パスワード再設定メールを送信しました"
    redirect_to new_password_reset_url
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      flash[:dangerous] = "パスワードを入力してください"
      render 'edit'
    elsif @user.update(user_params)
      flash[:notice] = "パスワードを更新しました"
      @user.reset_digest = nil
      @user.reset_sent_at = nil
      redirect_to login_url
    else
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

    def get_user
      @user = User.find_by(email: params[:email].downcase)
    end

    def exist_user
      if @user.nil?
        flash[:dangerous] = "このメールアドレスは登録されていません"
        redirect_to new_password_reset_url
      end
    end

    def activated_user
      if !@user.activated?
        @user.delete_session_token
        session[:user_id] = nil
        @user.restart_activation
        flash[:dangerous] = "メールアドレスの認証がまだです。認証メールを送信しました。"
        redirect_to email_authentication_url(email: @user.email)
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:dangerous] = "認証に失敗しました。はじめからやり直してください。"
        redirect_to new_password_reset_url
      end
    end

    def correct_token
      if !@user.authenticated?(:reset, params[:id])
        flash[:dangerous] = "認証に失敗しました。はじめからやり直してください。"
        redirect_to login_url
      end  
    end
end
