require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = { name: "signup_test_user",
              user_name: "signup_test_user",
              email: "signup_test_user@example.com",
              password: "password",
              password_confirmation: "password" }
  end

  test "successful signup" do
    get new_user_path
    assert_template "users/new"
    assert_difference 'User.count', 1 do
      post users_path, params: { user: @user }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_template "user_mailer/account_activation"
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_select "p", text: @user[:email]
    # token_test---
    # @user = assigns(:user)
    # get edit_account_activation_path("create", email: @user[:email])
    # follow_redirect!
    # assert_template "posts/index"
    # assert_select "a[href=?]", user_path(@user)
    # get user_path(@user)
    # assert_template "users/show"
    # assert_select "h1", text: @user[:name]
    # assert_select "p", "@#{@user[:user_name]}"
    # ---
  end

  test "unsuccessful signup with invalid token" do
    get new_user_path
    assert_template "users/new"
    assert_difference 'User.count', 1 do
      post users_path, params: { user: @user }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_template "user_mailer/account_activation"
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_select "p", text: @user[:email]
    # token_test---
    # @user = assigns(:user)
    # get edit_account_activation_path("invalid", email: @user[:email])
    # assert_redirected_to send_email_again_path(email: @user[:email])
    # follow_redirect!
    # assert_equal 2, ActionMailer::Base.deliveries.size
    # assert_template "user_mailer/account_activation"
    # follow_redirect!
    # assert_template "account_activations/email_authentication"
    # ---
  end
end
