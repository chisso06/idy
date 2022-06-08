require "test_helper"

class EditEmailTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:hanako)
  end

  test "successful activate after edit email from setting-page" do
    login(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    assert_select "a[href=?]", "/edit_email/#{@user[:user_name]}"
    get "/edit_email/#{@user[:user_name]}"
    assert_template "users/edit_email_form"
    email = "edit_email_again_test@example.com"
    post "/edit_email/#{@user[:user_name]}", params: { email: email, 
                                                       password: "password" }
    token = assigns(:user).activation_token
    assert_equal 1, ActionMailer::Base.deliveries.size
    follow_redirect!
    assert_template "account_activations/email_authentication"
    assert_select "p", text: email
    get edit_account_activation_path(token, email: email)
    follow_redirect!
    assert_template "posts/index"
    assert_select "a[href=?]", user_path(@user)
    get user_path(@user)
    assert_template "users/show"
    assert_select "h1", text: @user[:name]
    assert_select "p", "@#{@user[:user_name]}"
  end
end
