require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
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
    follow_redirect!
    assert_template "posts/index"
    assert_select "a[href=?]", user_path("signup_test_user")
    get user_path("signup_test_user")
    assert_template "users/show"
    assert_select "h1", text: "signup_test_user"
    assert_select "p", "@signup_test_user"
  end
end
