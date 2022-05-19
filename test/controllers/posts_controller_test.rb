require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @dum_user = users(:tarou)
    @post = posts(:test)
  end

  test "should not access when not logged in" do
    get new_post_path
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "should not edit by defferent user" do
    login(@dum_user)
    get edit_post_path(@post)
    assert_not flash.empty?
    assert_redirected_to posts_path
  end

  test "should not update by defferent user" do
    login(@dum_user)
    patch post_path(@post)
    assert_not flash.empty?
    assert_redirected_to posts_path
  end

  test "should not destroy by defferent user" do
    login(@dum_user)
    delete post_path(@post)
    assert_not flash.empty?
    assert_redirected_to posts_path
  end
end
