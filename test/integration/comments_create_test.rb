require "test_helper"

class CommentCreateTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
    @post = posts(:test)
  end

  test "successful create comment" do
    login(@user)
    get post_path(@post)
    assert_template "posts/show"
    assert_select "p", text: "create_test_comment", count: 0
    assert_select "input", value: "コメントを追加"
    assert_difference('Comment.count', 1) do
      post post_comments_path(@post), params: {content: "create_test_comment"}
    end
    follow_redirect!
    assert_template "posts/show"
    assert_select "p", text: "create_test_comment", count: 1
  end
end
