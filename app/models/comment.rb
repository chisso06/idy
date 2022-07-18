class Comment < ApplicationRecord
	validates :user_id, presence: true
	validates :post_id, presence: true
  validates :content, presence: true

	def user
		User.find_by(id: self.user_id)
	end

	def post
		Post.find_by(id: self.post_id)
	end
end
