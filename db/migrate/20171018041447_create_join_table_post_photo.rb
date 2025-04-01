class CreateJoinTablePostPhoto < ActiveRecord::Migration[5.1]
  def change
    create_join_table :posts, :photos do |t|
      # t.index [:post_id, :photo_id]
      # t.index [:photo_id, :post_id]
    end
  end
end
