require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
    @post = posts(:test)
  end

  test "should get index" do
    login(@user)
    get post_path(@post)
    get likes_path
    assert_response :success
  end

  test "unsuccessful access when not logged in" do
    post likes_path
    assert_not flash[:dangerous].nil?
    assert_redirected_to login_path
    follow_redirect!
    assert_response :success
  end

  test "unsuccessful access without post_id session" do
    login(@user)
    post likes_path
    assert_not flash[:dangerous].nil?
    assert_redirected_to posts_path
    follow_redirect!
    assert_response :success
  end
end
