class RemoveHeroImageUrlFromPosts < ActiveRecord::Migration[5.1]
  def change
  	remove_column :posts, :hero_image_url
  end
end
