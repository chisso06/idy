require "test_helper"

class UsersDestroyTest < ActionDispatch::IntegrationTest
  def setup
		@user = users(:hanako)
    @user1 = users(:tarou)
	end

	test "successful user destroy" do
		login(@user)
    get posts_path
    assert_template "posts/index"
    assert_select "a", text: "hanako"
		get "/destroy/#{@user[:user_name]}"
		assert_template "users/destroy_form"
		assert_select "input", value: "退会する"
		assert_difference 'User.count', -1 do
			delete user_path(@user), params: { password: "password" }
		end
		follow_redirect!
		assert_template "home/top"
    login(@user1)
    get posts_path
    assert_template "posts/index"
    assert_select "a", text: "hanako", count: 0
	end
end
