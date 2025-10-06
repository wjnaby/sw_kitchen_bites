# db/migrate/20250925120000_create_recipes.rb
class CreateRecipes < ActiveRecord::Migration[6.1]
  def change
    create_table :recipes do |t|
      t.string :title, null: false
      t.text :ingredients
      t.text :instructions
      t.integer :cooking_time

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
