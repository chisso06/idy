require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
    @user1 = users(:tarou)
  end

  #should get test

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

  test "should get show" do
    login(@user)
    get user_path(@user)
    assert_template "users/show"
    assert_response :success
    get user_path(@user1)
    assert_template "users/show"
    assert_response :success
  end

  test "should get destroy_form" do
    login(@user)
    get destroy_path
    assert_template "users/destroy_form"
    assert_response :success
  end

  #before_action test

  test "before_action: login_user" do
    get user_path(@user)
    assert_not flash[:dangerous].nil?
    assert_redirected_to login_path
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

  #each action test
  test "successful create" do
    post users_path, params: { user: { name: "sample",
                                       user_name: "sample",
                                       email: "sample@example.com",
                                       password: "password",
                                       password_confirmation: "password" } }
    assert_not flash[:notice].nil?
    follow_redirect!
    assert_template "posts/index"
    assert_response :success
  end

  test "unsuccessful create without enough data" do
    post users_path, params: { user: { name: "",
                                       user_name: "sample",
                                       email: "sample@example.com",
                                       password: "password",
                                       password_confirmation: "password" } }
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

  test "unsuccessful login without enough data" do
    post login_path(user_name: "",
                    password: "")
    assert_not flash[:dangerous].nil?
    assert_template "users/login_form"
    assert_response :success
  end

  test "unsuccessful login with wrong password" do
    post login_path(user_name: "",
                    password: "")
    assert_not flash[:dangerous].nil?
    assert_template "users/login_form"
    assert_response :success
  end

  test "successful logout" do
    login(@user)
    post logout_path
    assert_not flash[:notice].nil?
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
