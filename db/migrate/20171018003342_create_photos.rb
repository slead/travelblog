class CreatePhotos < ActiveRecord::Migration[5.1]
  def change
    create_table :photos do |t|
      t.string :flickr_id
      t.string :title
      t.text :description
      t.date :date_taken
      t.string :thumb
      t.string :small
      t.string :medium
      t.string :large

      t.timestamps
    end
  end
end
