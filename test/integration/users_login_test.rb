require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
  end

  test "should not login with invalid email" do
    get login_path
    assert_template "users/login_form"
    post login_path, params: { user: { email: "tarou@example.com",
                                       password: "password" } }
    assert_template "users/login_form"
    assert session[:id].nil?
    assert_not flash.empty?
  end

  test "should not login with invalid password" do
    get login_path
    assert_template "users/login_form"
    post login_path, params: { user: { email: "hanako@example.com",
                                       password: "wordpass" } }
    assert_template "users/login_form"
    assert session[:id].nil?
    assert_not flash.empty?
  end

  test "login with valid email/password" do
    get login_path
    assert_template "users/login_form"
    post login_path, params: { user: { email: "hanako@example.com",
                                       password: "password" } }
    follow_redirect!
    assert_template "users/show"
    assert_not session[:id].nil?
    assert_not flash.empty?
  end
end
