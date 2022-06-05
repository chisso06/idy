require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(
      hashed_id: "sample",
      name: "a" * 30,
      user_name: "sample",
      email: "sample@example.com",
      password: "password",
      password_confirmation: "password",
      image: "admin.png",
      biography: "a" * 150,
    )
  end

  test "should be valid" do
    assert @user.valid?
  end

  #hashed_id test
  test "hashed_id should be presence" do
    @user.hashed_id = ""
    assert_not @user.valid?
  end

  test "hashed_id should be unique" do
    user = User.create(
      hashed_id: "sample",
      name: "sample2",
      user_name: "sample2",
      email: "sample2@example.com",
      password: "password",
      password_confirmation: "password",
      image: "admin.png"
    )
    assert_not @user.valid?
  end

  # name test
  test "name should be presence" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 31
    assert_not @user.valid?
  end

  test "name validation should accept valid string" do
    valid_strings = ["a", "A", "0", "あ", "ア", "ｱ", ".", "a ", "a a", "a."]
    valid_strings.each do |string|
      @user.name = string
      assert @user.valid?, "#{string} didn't accept"
    end
  end

  test "name validation should reject invalid string" do
    invalid_strings = ["    ", " a"]
    invalid_strings.each do |string|
      @user.name = string
      assert_not @user.valid?, "#{string} didn't reject"
    end
  end

  # user_name test
  test "user_name should be presence" do
    @user.user_name = ""
    assert_not @user.valid?
  end

  test "user_name should not be too short" do
    @user.user_name = "a" * 2
    assert_not @user.valid?
  end

  test "user_name should not be too long" do
    @user.user_name = "a" * 21
    assert_not @user.valid?
  end

  test "user_name validation should accept valid string" do
    valid_strings = %w[aaaa AAAA 0000 a___ a__a ___a aadmin]
    valid_strings.each do |string|
      @user.user_name = string
      assert @user.valid?, "#{string} didn't accept"
    end
  end

  test "user_name validation should reject invalid string" do
    invalid_strings = ["____", "aa a", "aa.a", "admin", "Adminabc"]
    invalid_strings.each do |string|
      @user.user_name = string
      assert_not @user.valid?, "#{string} didn't refect"
    end
  end

  test "user_name should be unique" do
    user = User.create(
      hashed_id: "sample2",
      name: "sample2",
      user_name: "sample",
      email: "sample2@example.com",
      password: "password",
      password_confirmation: "password",
      image: "admin.png"
    )
    assert_not @user.valid?
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
    user = User.new(
      hashed_id: "sample2",
      name: "sample2",
      user_name: "sample2",
      email: "sample@example.com",
      password: "password",
      password_confirmation: "password",
      image: "admin.png"
    )
    user.save
    assert_not @user.valid?
  end

  # password test
  test "password should be presence" do
    @user.password = @user.password_confirmation = ""
    assert_not @user.valid?
  end

  test "password should not be too short" do
    @user.password = "a" * 5
    assert_not @user.valid?
  end

  #image test
  test "image should be presence" do
    @user.image = ""
    assert_not @user.valid?
  end

  #biography test
  test "biography should not be too long" do
    @user.biography = "a" * 151
    assert_not @user.valid?
  end
end
