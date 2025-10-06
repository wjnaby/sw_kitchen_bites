class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe

  def create
    @recipe.likes.create(user: current_user) unless @recipe.likes.exists?(user: current_user)
    redirect_back(fallback_location: feed_path)
  end

  def destroy
    like = @recipe.likes.find_by(user: current_user)
    like&.destroy
    redirect_back(fallback_location: feed_path)
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end
end
