class Tag < ApplicationRecord

	VALID_TAG_REGEX = "\A#\w+\z"
	validates :tag, uniqueness: { case_sensitive: true }
end
