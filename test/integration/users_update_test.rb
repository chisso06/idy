require "test_helper"

class UsersUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:hanako)
  end

  test "unsuccessful edit" do
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), params: { user: { name: "",
                                              user_name: "",
                                              email: "",
                                              password: "pass",
                                              password_confirmation: "word" } }
    assert_template "users/edit"
    assert_not flash.empty?
  end
end
