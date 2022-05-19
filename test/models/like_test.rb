require "test_helper"

class LikeTest < ActiveSupport::TestCase
  def setup
    @like = Like.new(
      user_id: 1,
      post_id: 1
    )
  end

  test "should be valid" do
    assert @like.valid?
  end

  test "user_id should be presence" do
    @like.user_id = ""
    assert_not @like.valid?
  end

  test "post_id should be presence" do
    @like.post_id = ""
    assert_not @like.valid?
  end
end
