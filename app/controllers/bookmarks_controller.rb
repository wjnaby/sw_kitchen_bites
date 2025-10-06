class BookmarksController < ApplicationController
  before_action :authenticate_user!

  # Show all recipes bookmarked by the current user
  def index
    @recipes = current_user.bookmarked_recipes.includes(images_attachments: :blob)
  end

  # Bookmark a recipe
  def create
    recipe = Recipe.find(params[:recipe_id])
    current_user.bookmarks.find_or_create_by(recipe: recipe)
    redirect_to recipe_path(recipe), notice: "Recipe bookmarked!"
  end

  # Remove bookmark
  def destroy
    recipe = Recipe.find(params[:recipe_id])
    current_user.bookmarks.find_by(recipe: recipe)&.destroy
    redirect_to recipe_path(recipe), notice: "Bookmark removed!"
  end
end
