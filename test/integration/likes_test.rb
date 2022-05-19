require "test_helper"

class LikesTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
    @post = posts(:test)
    @post1 = posts(:test1)
    @like = likes(:test)
  end

  test "successful create like" do
    login(@user)
    get post_path(@post1)
    assert_template "posts/show"
    assert_select "p", text: "いいねする"
    assert_difference('Like.count', 1) do
      post likes_path
    end
    assert_redirected_to post_path(@post1)
    follow_redirect!
    assert_response :success
  end

  test "successful cansel like" do
    login(@user)
    get post_path(@post)
    assert_template "posts/show"
    assert_select "p", text: "いいねを取り消す"
    assert_difference('Like.count', -1) do
      delete like_path(@like)
    end
    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_response :success
  end
end
