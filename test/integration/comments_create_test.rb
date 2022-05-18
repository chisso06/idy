require "test_helper"

class CommentCreateTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:tarou)
    @post = posts(:test)
  end

  test "successful create comment" do
    login(@user)
    get post_path(@post)
    assert_select "button", text: "削除", count: 0
    assert_select "a[href=?]", user_path(@user), text: @user.name, count: 0
    assert_difference('Comment.count', 1) do
      post comments_path(comment: {content: "test"})
    end
    follow_redirect!
    assert_select "button", text: "削除", count: 1
    assert_select "a[href=?]", user_path(@user), text: @user.name, count: 1
  end
end
