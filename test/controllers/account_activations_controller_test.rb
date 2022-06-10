require "test_helper"

class AccountActivationsControllerTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:hanako)
    @user.new_email = "new_email@example.com"
    @user.save
  end

  # should get test
  test "should get email_authentication" do
    get email_authentication_path(email: @user.new_email)
    assert_template "account_activations/email_authentication"
    assert_response :success
  end

  test "should get send_email_again" do
    get send_email_again_path(email: @user.new_email)
    assert_redirected_to email_authentication_path(email: @user.email)
    follow_redirect!
    assert_template "account_activations/email_authentication"
  end

  # before_action test
  test "before_action: exist_user" do
    get email_authentication_path(email: "invalid")
    assert_not flash[:dangerous].nil?
    assert_redirected_to new_user_path
    follow_redirect!
    assert_template "users/new"
  end

  test "before_action: not_activated_user(not login user)" do
    user = users(:tarou)
    get email_authentication_path(email: user.email)
    assert_not flash[:notice].nil?
    assert_redirected_to login_path
    follow_redirect!
    assert_template "users/login_form"
  end

  test "before_action: not_activated_user(login user)" do
    user = users(:tarou)
    login(user)
    get email_authentication_path(email: user.email)
    assert_not flash[:notice].nil?
    assert_redirected_to posts_path
    follow_redirect!
    assert_template "posts/index"
  end

  # each action test
  test "successful send_email_again" do
    get send_email_again_path(email: @user.new_email)
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert flash[:notice]
    assert_template "user_mailer/account_activation"
    assert_redirected_to "/email_authentication?email=#{CGI.escape(@user.new_email)}"
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_response :success
  end

  test "successful account_activation" do
    @user[:activation_digest] = BCrypt::Password.create("test")
    @user.save
    get edit_account_activation_path("test", email: @user.new_email)
    assert_not @user.activated?
    assert_not @user[:activated_at].nil?
    assert flash[:dangerous].nil?, flash[:dangerous]
    assert_not flash[:notice].nil?
    assert_redirected_to posts_path
    follow_redirect!
    assert_template "posts/index"
    assert_response :success
  end

  test "unsuccessful account_activaion with invalid token" do
    @user[:activation_digest] = BCrypt::Password.create("test")
    @user.save
    get edit_account_activation_path("invalid", email: @user.new_email)
    assert_not flash[:dangerous].nil?
    assert_redirected_to send_email_again_path(email: @user.new_email)
  end
end
