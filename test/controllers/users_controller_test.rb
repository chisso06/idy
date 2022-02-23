require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
  end

  test "should get new" do
    get new_user_path
    assert_response :success
  end

  test "should get login_form" do
    get login_path
    assert_response :success
  end

  test "should get edit" do
    get edit_user_path(@user)
    assert_response :success
  end

  test "should get show" do
    get user_path(@user)
    assert_response :success
  end

  test "should get index" do
    get users_path
    assert_response :success
  end


end
