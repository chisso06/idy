require "test_helper"

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    user = users(:hanako)
    user.activation_token = SecureRandom.urlsafe_base64
    mail = UserMailer.account_activation(user)
    assert_equal "Idy | メール認証",        mail.subject
    assert_equal [user.email],            mail.to
    assert_equal ["milia4364@gmail.com"], mail.from
    assert_match user.name,              mail.body.encoded.split("\r\n").map{|i| Base64.decode64(i)}.join
    assert_match user.activation_token,  mail.body.encoded.split("\r\n").map{|i| Base64.decode64(i)}.join
    assert_match CGI.escape(user.email), mail.body.encoded.split("\r\n").map{|i| Base64.decode64(i)}.join
  end
end
