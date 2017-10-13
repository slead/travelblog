class AddLatitudeAndLongitudeToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :city, :string
    add_column :posts, :state, :string
    add_column :posts, :country, :string
    add_column :posts, :latitude, :float
    add_column :posts, :longitude, :float
  end
end
