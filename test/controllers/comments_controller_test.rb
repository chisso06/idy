require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
    @user1 = users(:tarou)
    @post = posts(:test)
    @post1 = posts(:test1)
    @comment = comments(:test)
  end

  test "unsuccessful comment when not logged in" do
    get post_path(@post)
    post post_comments_path(@post)
    assert_not flash[:dangerous].nil?
    assert_redirected_to login_path
    follow_redirect!
    assert_response :success
  end

  test "successful comment" do
    login(@user)
    get post_path(@post)
    post post_comments_path(@post), params: {content: "test"}
    assert_not flash[:notice].nil?
    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_response :success
  end

  test "unsuccessful destroy comment of other user" do
    login(@user1)
    get post_path(@post)
    delete post_comment_path(@post, @comment)
    assert_not flash[:dangerous].nil?
    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_response :success
  end

  test "successful destroy comment" do
    login(@user)
    get post_path(@post)
    delete post_comment_path(@post, @comment)
    assert_not flash[:notice].nil?
    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_response :success
  end
end
