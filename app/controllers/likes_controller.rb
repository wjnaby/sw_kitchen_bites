class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe

  # POST /recipes/:recipe_id/like
  def create
    unless @recipe.likes.exists?(user: current_user)
      @recipe.likes.create(user: current_user)
    end

    respond_to do |format|
      format.html { redirect_back(fallback_location: feed_path) } # fallback for normal requests
      format.json { render json: { liked: true, count: @recipe.likes.count } } # AJAX response
    end
  end

  # DELETE /recipes/:recipe_id/like
  def destroy
    like = @recipe.likes.find_by(user: current_user)
    like&.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: feed_path) } # fallback for normal requests
      format.json { render json: { liked: false, count: @recipe.likes.count } } # AJAX response
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end
end
