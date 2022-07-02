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
  validates :email,     length: { maximum: 255 },
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: { case_sensitive: false },
                        allow_nil: true

  validates :new_email, length: { maximum: 255 },
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: { case_sensitive: false },
                        allow_nil: true 

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
    self.save
  end

  def send_activation_email
    UserMailer::account_activation(self).deliver_now
  end

  def restart_activation
    self.create_activation_token_and_digest
    self.send_activation_email
  end

  # session
  def create_session_token
    token = SecureRandom.alphanumeric(8)
    self.session_token = token
    self.session_created_at = Time.zone.now
    self.save
    return token
  end

  def delete_session_token
    self.session_token = nil
    self.session_created_at = nil
  end

  def session_expired?
    return true if session_created_at.nil?
    session_created_at < 24.hours.ago
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
    if self.reset_sent_at
      self.reset_sent_at < 2.hours.ago
    end
  end

  # authenticate
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    return false if token.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # image
  def make_image(image)
    if self.image.include?(self.user_name)
      File.delete("public/user_icons/#{self.image}")
    end
    if image.original_filename.include?(".png") or image.original_filename.include?(".PNG")
      extension = ".png"
    else
      extension = ".jpg"
    end
    self.image = self.user_name + extension
    File.binwrite("public/user_icons/#{self.image}", image.read)
  end
end
