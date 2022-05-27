class User < ApplicationRecord
  has_secure_password

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
end
