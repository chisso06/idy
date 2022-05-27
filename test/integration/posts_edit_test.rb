require "test_helper"

class PostsEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:hanako)
    @post = posts(:test)
  end

  test "unsuccessful edit" do
    login(@user)
    get edit_post_path(@post)
    assert_template "posts/edit"
    patch post_path(@post), params: { post: { title: "",
                                              category: "",
                                              content: "" } }
    assert_equal "test", @post.reload.title
    assert_template "posts/edit"
    assert_not flash.empty?
  end

  test "successful edit" do
    login(@user)
    get edit_post_path(@post)
    assert_template "posts/edit"
    patch post_path(@post), params: { post: { title: "edit",
                                              category: "edit",
                                              content: "edit" } }
    assert_equal "edit", @post.reload.title
    assert_redirected_to post_path(@post)
    assert_not flash.empty?
  end
end
