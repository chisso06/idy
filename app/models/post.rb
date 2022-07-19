class Post < ApplicationRecord
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  validates :title, presence: true, length: { maximum: 20 }
  validates :content, presence: true, length: { maximum: 400 }
  validates :user_id, presence: true

  def user
    User.find_by(id: self.user_id)
  end

  def like_users
		likes = Like.where(post_id: self.id)
		users = []
		likes.each do |like|
			users.push(User.find_by(id: like.user_id))
		end
		return users
	end
end
