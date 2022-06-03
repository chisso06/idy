require "test_helper"

class AccountActivationsSendEmailAgainTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:hanako)
    @user[:activated] = false
    @user.activation_digest = BCrypt::Password.create("test")
    @user.save
  end

  test "successful activate after sending email again" do
    get email_authentication_path(email: @user[:email])
    assert_template "account_activations/email_authentication"
    assert_select "p", text: @user[:email]
    assert_select "a[href=?]", send_email_again_path(email: @user[:email])
    get send_email_again_path(email: @user[:email])
    assert_equal 1, ActionMailer::Base.deliveries.size
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_select "p", text: @user[:email]
    # token_test---
    # @user = assigns(:user)
    # get edit_account_activation_path("send_email_again", email: @user[:email])
    # follow_redirect!
    # assert_template "posts/index"
    # assert_select "a[href=?]", user_path(@user)
    # get user_path(@user)
    # assert_template "users/show"
    # assert_select "h1", text: @user[:name]
    # assert_select "p", "@#{@user[:user_name]}"
    # ---
  end

  test "unsuccessful activate after sending email again with prev-token" do
    get email_authentication_path(email: @user[:email])
    assert_template "account_activations/email_authentication"
    assert_select "a[href=?]", send_email_again_path(email: @user[:email])
    get send_email_again_path(email: @user[:email])
    assert_equal 1, ActionMailer::Base.deliveries.size
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_select "p", text: @user[:email]
    # token test---
    # @user = assigns(:user)
    # get edit_account_activation_path("test", email: @user[:email])
    # assert_redirected_to send_email_again_path(email: @user[:email])
    # follow_redirect!
    # assert_equal 2, ActionMailer::Base.deliveries.size
    # assert_template "user_mailer/account_activation"
    # follow_redirect!
    # assert_template "account_activations/email_authentication"
    # ---
  end
end
