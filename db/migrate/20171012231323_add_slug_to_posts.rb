class AddSlugToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :slug, :string, unique: true
  end
end
