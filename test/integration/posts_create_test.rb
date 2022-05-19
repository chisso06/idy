require "test_helper"

class PostsCreateTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
    @post = posts(:test)
  end

  test "invalid post" do
    login(@user)
    get new_post_path
    assert_no_difference 'Post.count' do
      post posts_path, params: { post: { title: "",
                                         category: "",
                                         content: "" } }
    end
    assert_template "posts/new"
    assert flash.empty?
  end

  test "valid post" do
    login(@user)
    get new_post_path
    assert_difference 'Post.count', 1 do
      post posts_path, params: { post: { title: "test",
                                         category: "test",
                                         content: "test" } }
    end
    follow_redirect!
    assert_template "posts/show"
    assert_not flash.empty?
  end
end
