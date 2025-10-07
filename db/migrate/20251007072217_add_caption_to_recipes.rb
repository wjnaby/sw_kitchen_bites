class AddCaptionToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :caption, :string
  end
end
