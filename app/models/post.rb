class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 20 }
  validates :content, presence: true
  validates :user_id, presence: true

  def user
    User.find(self.user_id)
  end
end
