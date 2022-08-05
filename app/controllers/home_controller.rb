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
      { title: "ユーザー登録をしようとすると、「内容に不備があります」と表示されます", text: "登録できるユーザーの情報には以下のような制約があります\n・Nameは1〜30字。先頭にスペースを置くことはできません\n・Usernameは3字以上20字以内の未登録のものである必要があります。英数字および「_(アンダーバー)」以外の文字は使用できません。\n・emailは255字以内の未登録のメールアドレスである必要があります。\n・Passwordは6文字以上である必要があります。\nPassword（確認）はパスワードと一致している必要があります。\n以上の制約を満たしていない場合、登録ができません" },
      { title: "ユーザーの設定が更新できません", text: "ユーザーの情報には以下のような制約があります\n・Nameは1〜30字。先頭にスペースを置くことはできません\n・Bioは150字以内\n以上の制約を満たしていない場合、設定を更新することはできません" },
      { title: "投稿が保存できません", text: "ユーザーの情報には以下のような制約があります\n・タイトルは20字以内\n・内容は400字以内\n以上の制約を満たしていない場合、投稿を保存することはできません" },
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
