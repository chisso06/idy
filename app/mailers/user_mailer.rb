class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    mail to: user.new_email, subject: "idy | メール認証"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "idy | パスワード再設定"
  end
end
