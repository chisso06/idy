require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @post = Post.new(
      title: "title",
      content: "content",
      category: "category",
      user_id: "1"
    )
  end

  test "should be valid" do
    assert @post.valid?
  end

  test "title should be presence" do
    @post.title = ""
    assert_not @post.valid?
  end

  test "title should not be too long" do
    @post.title = "a" * 21
    assert_not @post.valid?
  end

  test "category should be presence" do
    @post.category = ""
    assert_not @post.valid?
  end

  test "content should be presence" do
    @post.content = ""
    assert_not @post.valid?
  end

  test "user_id should be presence" do
    @post.user_id = ""
    assert_not @post.valid?
  end
end
