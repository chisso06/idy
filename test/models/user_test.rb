require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(
      name: "sample",
      user_name: "sample",
      email: "sample@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  test "should be valid" do
    assert @user.valid?
  end

  # name test
  test "name should be presence" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 21
    assert_not @user.valid?
  end

  # user_name test
  test "user_name should be presence" do
    @user.user_name = ""
    assert_not @user.valid?
  end

  test "user_name should not be too long" do
    @user.user_name = "a" * 21
    assert_not @user.valid?
  end

  test "user_name validation should accept valid string" do
    valid_strings = %w[a0 0a a_ 0_ a__a]
    valid_strings.each do |string|
      @user.user_name = string
      assert @user.valid?, "#{string} didn't accept"
    end
  end

  test "user_name validation should reject invalid string" do
    invalid_strings = %w[a A aA _ _a _0 __ a. a+ a-]
    invalid_strings.each do |string|
      @user.user_name = string
      assert_not @user.valid?, "#{string} didn't refect"
    end
  end

  test "user_name should be unique" do
    same_user_name_user = User.new(
      name: "sample2",
      user_name: "sample",
      email: "sample2@example.com",
      password: "password",
      password_confirmation: "password"
    )
    @user.save
    assert_not same_user_name_user.valid?
  end

  # email test
  test "email should be presence" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "email shold not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo @bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?
    end
  end

  test "email should be unique" do
    same_email_user = User.new(
      name: "sample2",
      user_name: "sample2",
      email: "sample@example.com",
      password: "password",
      password_confirmation: "password"
    )
    @user.save
    assert_not same_email_user.valid?
  end

  # password test
  test "password should be presence" do
    @user.password = @user.password_confirmation = ""
    assert_not @user.valid?
  end

  test "password should not be too short" do
    @user.password = "a" * 5
  end
end
