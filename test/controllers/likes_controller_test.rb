require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hanako)
  end

  test "should not access when not logged in" do
    get "/likes/index/1"
    assert_not flash.empty?
    assert_redirected_to login_url
  end
end
