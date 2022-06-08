require "test_helper"

class AccountActivationsSendEmailAgainTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:hanako)
    @user.activated = false
    @user.save
  end

  test "successful activate after sending email again" do
    get email_authentication_path(email: @user[:email])
    assert_template "account_activations/email_authentication"
    assert_select "p", text: @user[:email]
    assert_select "a[href=?]", send_email_again_path(email: @user[:email])
    get send_email_again_path(email: @user[:email])
    token = assigns(:user).activation_token
    assert_equal 1, ActionMailer::Base.deliveries.size
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_select "p", text: @user[:email]
    get edit_account_activation_path(token, email: @user[:email])
    follow_redirect!
    assert_template "posts/index"
    assert_select "a[href=?]", user_path(@user)
    get user_path(@user)
    assert_template "users/show"
    assert_select "h1", text: @user[:name]
    assert_select "p", "@#{@user[:user_name]}"
  end

  test "unsuccessful activate after sending email again with prev-token" do
    prev_token = "test"
    @user.activation_digest = BCrypt::Password.create(prev_token)
    @user.save
    get email_authentication_path(email: @user[:email])
    assert_template "account_activations/email_authentication"
    assert_select "a[href=?]", send_email_again_path(email: @user[:email])
    get send_email_again_path(email: @user[:email])
    token = assigns(:user).activation_token
    assert_equal 1, ActionMailer::Base.deliveries.size
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_select "p", text: @user[:email]
    get edit_account_activation_path(prev_token, email: @user[:email])
    assert_redirected_to send_email_again_path(email: @user[:email])
    follow_redirect!
    assert_equal 2, ActionMailer::Base.deliveries.size
    assert_template "user_mailer/account_activation"
    follow_redirect!
    assert_template "account_activations/email_authentication"
  end
end
