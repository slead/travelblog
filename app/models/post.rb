class Post < ApplicationRecord
	include FriendlyId
	friendly_id :title, use: :slugged
end
