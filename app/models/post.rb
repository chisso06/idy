class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 20 }
  validates :content, presence: true
  validates :user_id, presence: true

  def user
    User.find(self.user_id)
  end

  def create_tag
    content = self.content
    tags = content.slice(/#.*/)
    if (tags)
      tags = tags.split
		  tags.each do |tag|
        if (tag.match(/\A#\w+\z/))
          @tag = Tag.new(tag: tag)
          @tag.save
        end
      end
    end
  end
end
