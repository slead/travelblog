class CreateTips < ActiveRecord::Migration[5.1]
  def change
    create_table :tips do |t|
      t.string :title
      t.text :content
      t.timestamps
    end
  end
end
