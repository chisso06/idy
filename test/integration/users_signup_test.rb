require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get new_user_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "",
                                         user_name: "",
                                         email: "",
                                         password: "",
                                         password_confirmation: "" } }
    end
    assert_template "users/new"
    assert flash.empty?
  end

  test "valid signup information" do
    get new_user_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "user",
                                         user_name: "user",
                                         email: "user@example.com",
                                         password: "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template "/"
    assert_not flash.empty?
  end
end
