class AddSortIndexToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :sort, :integer
  end
end
