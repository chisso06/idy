class Like < ApplicationRecord
  validates :user_id, presence: true
	validates :post_id, presence: true
	def user
		return User.find(self.user_id)
	end
	
	def post
		return Post.find(self.post_id)
	end
end
