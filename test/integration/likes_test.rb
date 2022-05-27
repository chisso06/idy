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
      post post_likes_path(@post1)
    end
    follow_redirect!
    assert_template "posts/show"
    assert_select "p", text: "いいねを取り消す"
  end

  test "successful cansel like" do
    login(@user)
    get post_path(@post)
    assert_template "posts/show"
    assert_select "p", text: "いいねを取り消す"
    assert_difference('Like.count', -1) do
      delete post_like_path(@post, @like)
    end
    follow_redirect!
    assert_template "posts/show"
    assert_select "p", text: "いいねする"
  end
end
