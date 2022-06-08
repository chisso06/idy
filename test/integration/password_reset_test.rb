require "test_helper"

class PasswordResetTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:hanako)
  end

  test "successful reset password" do
    get login_url
    assert_template "users/login_form"
    assert_select "a[href=?]", new_password_reset_url
    get new_password_reset_url
    assert_template "password_resets/new"
    post password_resets_url(email: @user.email)
    token = assigns(:user).reset_token
    assert_equal 1, ActionMailer::Base.deliveries.size
    get edit_password_reset_url(token, email: @user.email)
    assert_template "password_resets/edit"
    patch password_reset_url(token),
          params: { email: @user.email,
                    user: { password: "new_password",
                            password_confirmation: "new_password" } }
    follow_redirect!
    assert_template "users/login_form"
    post login_url(user_name: @user.user_name,
                   password: "new_password")
    assert flash[:notice]
    follow_redirect!
    assert_template "posts/index"
  end
end
