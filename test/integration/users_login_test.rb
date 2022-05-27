require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
  end

  test "successful login" do
    get login_path
    assert_template "users/login_form"
    post login_path, params:  { user_name: "hanako",
                                password: "password" }
    follow_redirect!
    assert_template "posts/index"
    assert_select "a[href=?]", user_path(@user)
    get user_path(@user)
    assert_template "users/show"
    assert_select "h1", text: "hanako"
    assert_select "p", "@hanako"
  end
end
