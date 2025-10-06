class AddDescriptionToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :description, :text
  end
end
