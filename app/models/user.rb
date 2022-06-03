class User < ApplicationRecord
  has_secure_password
  attr_accessor :activation_token

  validates :hashed_id, presence: true,
                        uniqueness: true

  VALID_NAME_REGEX = /\A(?!\s).*\z/
  validates :name,      presence: true,
                        length: { maximum: 30 },
                        format: { with: VALID_NAME_REGEX }

  VALID_USER_NAME_REGEX = /(?=\A_*+[a-zA-Z0-6]+\w*\z)(?!admin)/i
  validates :user_name, presence: true,
                        length: { minimum: 3, maximum: 20 },
                        format: { with: VALID_USER_NAME_REGEX },
                        uniqueness: { case_sensitive: false }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,     presence: true,
                        length: { maximum: 255 },
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: { case_sensitive: false }

  validates :password,  presence: true,
                        length: { minimum: 6 },
                        allow_nil: true

  validates :image,     presence: true

  validates :biography, length: { maximum: 150 }

  validates :admin,     presence: true

  def to_param
    user_name
  end

  def create_activation_token_and_digest(test_token)
    if test_token.nil?
      token = SecureRandom.urlsafe_base64
    else
      token = test_token
    end
    self.activation_token = token
    self.activation_digest = BCrypt::Password.create(token)
  end

  def send_activation_email
    UserMailer::account_activation(self).deliver_now
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
end
