require "test_helper"

class UsersUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:hanako)
  end

  test "successful edit" do
    login(@user)
    get user_path(@user)
    assert_select "h1", text: "hanako"
    assert_select "a[href=?]", edit_user_path, text: "Setting", count: 1
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), params: { user: { name: "tarou",
                                              biography: "hello" } }
    follow_redirect!
    assert_template "users/show"
    assert_select "h1", text: "tarou"
    assert_select "p", text: "hello"
  end
end
