class AddFlickrAlbumToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :flickr_album, :string
  end
end
