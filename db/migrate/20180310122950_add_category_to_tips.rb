class AddCategoryToTips < ActiveRecord::Migration[5.1]
  def change
    add_column :tips, :category, :string
  end
end