require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @comment = Comment.new(
      user_id: 1,
      post_id: 1,
      content: "test"
    )
  end

  test "should be valid" do
    assert @comment.valid?
  end

  test "user_id should be presence" do
    @comment.user_id = ""
    assert_not @comment.valid?
  end

  test "post_id should be presence" do
    @comment.post_id = ""
    assert_not @comment.valid?
  end

  test "content should be presence" do
    @comment.content = ""
    assert_not @comment.valid?
  end
end
