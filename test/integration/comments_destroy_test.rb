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
    assert_select "button", text: "削除", count: 2
    assert_difference('Comment.count', -1) do
      delete comment_path(@comment)
    end
    follow_redirect!
    assert_select "button", text: "削除", count: 1
  end
end
