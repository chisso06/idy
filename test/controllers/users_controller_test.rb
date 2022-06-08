require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
    @user1 = users(:tarou)
  end

  # should get test

  test "should get new" do
    get new_user_path
    assert_template "users/new"
    assert_response :success
  end

  test "should get login_form" do
    get login_path
    assert_template "users/login_form"
    assert_response :success
  end

  test "should get edit" do
    login(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    assert_response :success
  end

  test "should get edit_email_form" do
    login(@user)
    get "/edit_email/#{@user[:user_name]}"
    assert_template "users/edit_email_form"
    assert_response :success
  end

  test "should get destroy_form" do
    login(@user)
    get "/destroy/#{@user[:user_name]}"
    assert_template "users/destroy_form"
    assert_response :success
  end

  test "should get show" do
    login(@user)
    get user_path(@user)
    assert_template "users/show"
    assert_response :success
    get user_path(@user1)
    assert_template "users/show"
    assert_response :success
  end  

  # before_action test

  test "before_action: login_user" do
    post logout_path
    assert_not flash[:dangerous].nil?
    assert_redirected_to login_path
    follow_redirect!
    assert_response :success
  end

  test "before_action: not_login_user" do
    login(@user)
    get new_user_path(@user)
    assert_redirected_to posts_path
    follow_redirect!
    assert_response :success
  end

  test "before_action: valid_user" do
    login(@user)
    get user_path("invalid")
    assert_not flash[:dangerous].nil?
    assert_redirected_to posts_path
    follow_redirect!
    assert_response :success
  end

  test "before_action: correct_user" do
    login(@user)
    get edit_user_path(@user1)
    assert_not flash[:dangerous].nil?
    assert_redirected_to posts_path
    follow_redirect!
    assert_response :success
  end

  # each action test
  test "successful create" do
    post users_path, params: { user: { name: "sample",
                                       user_name: "sample",
                                       email: "sample@example.com",
                                       password: "password",
                                       password_confirmation: "password" } }
    assert_template "user_mailer/account_activation"
    assert_redirected_to "/email_authentication?email=sample%40example.com"
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_response :success
  end

  test "unsuccessful create with registered email" do
    post users_path, params: { user: { name: "sample",
                                       user_name: "sample",
                                       email: @user[:email],
                                       password: "password",
                                       password_confirmation: "password" } }
    assert_not flash[:dangerous].nil?
    assert_redirected_to login_path
    follow_redirect!
    assert_template "users/login_form"
    assert_response :success
  end

  test "unsuccessful create without enough data" do
    post users_path, params: { user: { name: "",
                                       user_name: "",
                                       email: "",
                                       password: "",
                                       password_confirmation: "" } }
    assert_not flash[:dangerous].nil?                                   
    assert_template "users/new"
    assert_response :success
  end  

  test "successful login" do
    post login_path(user_name: @user.user_name,
                    password: "password")
    assert_not flash[:notice].nil?
    assert_redirected_to posts_path
    follow_redirect!
    assert_response :success
  end

  test "unsuccessful login as not_activated_user" do
    @user.activated = false
    @user.save
    post login_path(user_name: @user.user_name,
                    password: "password")
    assert_not flash[:dangerous].nil?
    assert flash[:notice].nil?, flash[:notice]
    assert_redirected_to email_authentication_url(email: @user.email)
    follow_redirect!
    assert_response :success
  end

  test "unsuccessful login without enough data" do
    post login_path(user_name: "",
                    password: "")
    assert_not flash[:dangerous].nil?
    assert_template "users/login_form"
    assert_response :success
  end

  test "unsuccessful login with wrong password" do
    post login_path(user_name: @user.user_name,
                    password: "")
    assert_not flash[:dangerous].nil?
    assert_template "users/login_form"
    assert_response :success
  end

  test "successful logout" do
    login(@user)
    post logout_path
    assert flash[:notice]
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "successful update" do
    login(@user)
    patch user_path(@user), params: { user: { name: "edit",
                                              biography: "edit" } }
    assert_not flash[:notice].nil?
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_response :success
  end
  
  test "unsuccessful update without enough data" do
    login(@user)
    patch user_path(@user), params: { user: { name: "",
                                              biography: "edit" } }
    assert_not flash[:dangerous].nil?
    assert_template "users/edit"
    assert_response :success
  end

  test "successful edit_email" do
    login(@user)
    email = "edit_email_test@example.com"
    post "/edit_email/#{@user.user_name}", params: { email: email,
                                                     password: "password" }
    assert_not flash[:notice].nil?
    assert_template "user_mailer/account_activation"
    assert_redirected_to "/email_authentication?email=edit_email_test%40example.com"
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_response :success
  end

  test "unsuccessful edit_email with same email-address" do
    login(@user)
    email = @user.email
    post "/edit_email/#{@user.user_name}", params: { email: email }
    assert_not flash[:dangerous].nil?
    assert_template "users/edit_email_form"
    assert_response :success
  end

  test "unsuccessful edit_email with invalid email-address" do
    login(@user)
    email = "invalid"
    post "/edit_email/#{@user.user_name}", params: { email: email }
    assert_not flash[:dangerous].nil?
    assert_template "users/edit_email_form"
    assert_response :success
  end

  test "successful destroy" do
    login(@user)
    delete user_path(@user), params: { password: "password" }
    assert_not flash[:notice].nil?
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "unsuccessful destroy with wrong password" do
    login(@user)
    delete user_path(@user), params: { password: "wrong" }
    assert_not flash[:dangerous].nil?
    assert_template "users/destroy_form"
    assert_response :success
  end
end
