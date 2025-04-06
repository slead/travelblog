class PlacenameToPosts < ActiveRecord::Migration[5.1]
  def change
  	add_column :posts, :placename, :string
  end
end
