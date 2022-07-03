require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:hanako)
  end

  # should get test
  test "should get new" do
    get new_password_reset_url
    assert_template "password_resets/new"
    assert_response :success
  end

  test "should get edit" do
    token = "test-token"
    @user.reset_digest = BCrypt::Password.create(token)
    @user.reset_sent_at = Time.zone.now
    @user.save
    get edit_password_reset_url(token), params: { email: @user.email }
    assert flash[:dangerous].nil?, flash[:dangerous]
    assert_template "password_resets/edit"
    assert_response :success
  end

  # before_action test
  test "before_action :exist_user" do
    token = "test-token"
    get password_resets_edit_url(token, email: "invalid")
    assert flash[:dangerous]
    assert_redirected_to new_password_reset_url
    follow_redirect!
    assert_template "password_resets/new"
    assert_response :success
  end

  test "before_action :activated_user" do
    token = "test-token"
    @user.activated = false
    @user.save
    get password_resets_edit_url(token, email: @user.email)
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert flash[:dangerous]
    assert_redirected_to email_authentication_url(email: @user.email)
    assert_template "user_mailer/account_activation"
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_response :success
  end

  test "before_action :check_expiration" do
    token = "check-expiration"
    @user.reset_digest = BCrypt::Password.create(token)
    @user.reset_sent_at = Time.zone.yesterday
    @user.save
    get password_resets_edit_url(token, email: @user.email)
    assert flash[:dangerous]
    assert_redirected_to new_password_reset_url
    follow_redirect!
    assert_template "password_resets/new"
    assert_response :success
  end

  # action test
  test "successful create" do
    post password_resets_url(email: @user.email)
    @user = assigns(:user)
    assert @user.reset_token
    assert @user.reset_digest
    assert @user.reset_sent_at
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert flash[:notice]
    assert_redirected_to new_password_reset_url
    follow_redirect!
    assert_template "password_resets/new"
  end

  test "successful update" do
    token = "successful_update_test"
    @user.reset_digest = BCrypt::Password.create(token)
    @user.reset_sent_at = Time.zone.now
    @user.save
    patch password_reset_url(token),
          params: { email: @user.email,
                    user: { password: "new_password",
                            password_confirmation: "new_password" } }
    assert flash[:dangerous].nil?, flash[:dangerous]
    assert flash[:notice]
    assert_redirected_to login_url
    follow_redirect!
    assert_template "users/login_form"
    assert_response :success
  end

  test "unsuccessful update without password" do
    token = "unsuccessful_update_test"
    @user.reset_digest = BCrypt::Password.create(token)
    @user.reset_sent_at = Time.zone.now
    @user.save
    patch password_reset_url(token),
          params: { email: @user.email,
                    user: { password: "",
                            password_confirmation: "" } }
    assert flash[:dangerous]
    assert_template "password_resets/edit"
    assert_response :success
  end

  test "unsuccessful update with invalid password" do
    token = "unsuccessful_update_test"
    @user.reset_digest = BCrypt::Password.create(token)
    @user.reset_sent_at = Time.zone.now
    @user.save
    patch password_reset_url(token),
          params: { email: @user.email,
                    user: { password: "a",
                            password_confirmation: "a" } }
    assert flash[:dangerous]
    assert_template "password_resets/edit"
    assert_response :success
  end
end
