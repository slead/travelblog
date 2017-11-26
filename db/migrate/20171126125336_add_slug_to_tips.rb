class AddSlugToTips < ActiveRecord::Migration[5.1]
  def change
    add_column :tips, :slug, :string, unique: true
  end
end
