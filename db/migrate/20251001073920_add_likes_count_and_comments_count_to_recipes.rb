class AddLikesCountAndCommentsCountToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :likes_count, :integer
    add_column :recipes, :comments_count, :integer
  end
end
