require "test_helper"

class LikesTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
    @post = posts(:test)
  end

  test "successful like at post_show page" do
    login(@user)
    get post_path(@post)
    assert_difference 'Like.count', 1 do
      post "/likes/new/#{@post.id}"
    end
  end

  test "successful destroy like at post_show page" do
    login(@user)
    post "/likes/new/#{@post.id}"
    get post_path(@post)
    assert_difference 'Like.count', -1 do
      delete "/likes/#{@post.id}"
    end
  end

  test "successful like at user_show page" do
    login(@user)
    get user_path(@user)
    assert_difference 'Like.count', 1 do
      post "/likes/new/#{@post.id}"
    end
  end

  test "successful destroy like at user_show page" do
    login(@user)
    post "/likes/new/#{@post.id}"
    get user_path(@user)
    assert_difference 'Like.count', -1 do
      delete "/likes/#{@post.id}"
    end
  end
end
