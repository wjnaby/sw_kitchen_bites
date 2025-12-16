class BookmarksController < ApplicationController
  before_action :authenticate_user!

  # Show all recipes bookmarked by the current user
  def index
    @recipes = current_user.bookmarked_recipes.includes(images_attachments: :blob)
  end

  # Bookmark a recipe
  def create
    recipe = Recipe.find(params[:recipe_id])
    bookmark = current_user.bookmarks.find_or_create_by(recipe: recipe)

    # Enqueue notification or analytics job
    BookmarkNotificationJob.perform_later(current_user.id, recipe.id)

    redirect_to recipe_path(recipe), notice: "Recipe bookmarked!"
  end

  # Remove bookmark
  def destroy
    recipe = Recipe.find(params[:recipe_id])
    bookmark = current_user.bookmarks.find_by(recipe: recipe)
    bookmark&.destroy

    # Optionally log bookmark removal in background
    BookmarkRemovalJob.perform_later(current_user.id, recipe.id) if bookmark

    redirect_to recipe_path(recipe), notice: "Bookmark removed!"
  end
end
