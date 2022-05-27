require "test_helper"

class CommentDestroyTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
    @post = posts(:test)
    @comment = comments(:test)
  end

  test "successful destroy comment" do
    login(@user)
    get post_path(@post)
    assert_template "posts/show"
    assert_select "p", text: "test_comment", count: 1
    assert_select "button", text: "コメントを削除"
    assert_difference('Comment.count', -1) do
      delete post_comment_path(@post, @comment)
    end
    follow_redirect!
    assert_select "p", text: "test_comment", count: 0
  end
end
