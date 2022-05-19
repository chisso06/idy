require "test_helper"

class PostsDestroyTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:hanako)
    @post = posts(:test)
  end

  test "destroy post" do
    login(@user)
    assert_difference 'Post.count', -1 do
      delete post_path(@post)
    end
    assert_redirected_to posts_path
    assert_not flash.empty?
  end
end
