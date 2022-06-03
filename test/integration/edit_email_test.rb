require "test_helper"

class EditEmailTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:hanako)
    @user[:activated] = false
    @user.activation_digest = BCrypt::Password.create("test")
    @user.save
  end

  test "successful activate after edit_email from email_authentication-page" do
    get email_authentication_path(email: @user[:email])
    assert_template "account_activations/email_authentication"
    assert_select "a[href=?]", "/edit_email/#{@user[:user_name]}"
    get "/edit_email/#{@user[:user_name]}"
    assert_template "users/edit_email_form"
    email = "edit_email_again_test@example.com"
    post "/edit_email/#{@user[:user_name]}", { params: { email: email, 
                                                         password: "password" } }
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_select "p", text: email
    # token test---
    @user = assigns(:user)
    get edit_account_activation_path("edit_email", email: @user[:email])
    follow_redirect!
    assert_template "posts/index"
    assert_select "a[href=?]", user_path(@user)
    get user_path(@user)
    assert_template "users/show"
    assert_select "h1", text: @user[:name]
    assert_select "p", "@#{@user[:user_name]}"
    # ---
  end

  test "successful activate after edit email from setting-page" do
    @user[:activated] = true
    @user.save
    login(@user)
    get edit_user_path(@user)
    assert_select "a[href=?]", "/edit_email/#{@user[:user_name]}"
    get "/edit_email/#{@user[:user_name]}"
    assert_template "users/edit_email_form"
    email = "edit_email_again_test@example.com"
    post "/edit_email/#{@user[:user_name]}", { params: { email: email, 
                                                         password: "password" } }
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_select "p", text: email
    # token_test---
    @user = assigns(:user)
    get edit_account_activation_path("edit_email", email: @user[:email])
    follow_redirect!
    assert_template "posts/index"
    assert_select "a[href=?]", user_path(@user)
    get user_path(@user)
    assert_template "users/show"
    assert_select "h1", text: @user[:name]
    assert_select "p", "@#{@user[:user_name]}"
    # ---
  end
end
