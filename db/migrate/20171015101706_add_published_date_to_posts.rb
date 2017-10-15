class AddPublishedDateToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :published_date, :date
  end
end
