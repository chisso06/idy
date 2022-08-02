class HomeController < ApplicationController
  before_action :login_user, only: :top

  def top
  end

  def help
    if @current_user
      destroy_form_url = "/destroy/#{@current_user.user_name}"
    else
      destroy_form_url = ""
    end
    @lists = [
      { title: "メールアドレスの変更方法を教えてください", text: "\"Mypage\" > 設定 > \"メールアドレス変更\" より変更できます。" },
      { title: "アカウントを削除する方法を教えてください", text: "" }
    ]
  end

  private
    def login_user
      if @current_user
        redirect_to posts_url
      end
    end
end
