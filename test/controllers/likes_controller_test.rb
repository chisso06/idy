require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
    @post = posts(:test)
  end

  test "should get index" do
    login(@user)
    get post_path(@post)
    get post_likes_path(@post)
    assert_template "likes/index"
    assert_response :success
  end

  test "unsuccessful access when not logged in" do
    post post_likes_path(@post)
    assert_not flash[:dangerous].nil?
    assert_redirected_to login_path
    follow_redirect!
    assert_template "users/login_form"
    assert_response :success
  end
end
