class User < ApplicationRecord
  has_secure_password
  attr_accessor :activation_token, :reset_token

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

  # params[:id]
  def to_param
    user_name
  end

  # activation
  def create_activation_token_and_digest
    token = SecureRandom.urlsafe_base64
    self.activation_token = token
    self.activation_digest = BCrypt::Password.create(token)
  end

  def send_activation_email
    UserMailer::account_activation(self).deliver_now
  end

  def restart_activation
		self.activated = false
    self.create_activation_token_and_digest
    self.save
    self.send_activation_email
  end

  # session
  def reset_session_token
    token = SecureRandom.alphanumeric(8)
    self.session_token = token
    self.save
    return token
  end

  # password reset
  def create_reset_token_and_digest
    token = SecureRandom.urlsafe_base64
    self.reset_token = token
    self.reset_digest = BCrypt::Password.create(token)
  end

  def send_password_reset_email
    UserMailer::password_reset(self).deliver_now
  end

  def password_reset_expired?
    return true if reset_sent_at.nil?
    reset_sent_at < 2.hours.ago
  end

  # authenticate
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
end
