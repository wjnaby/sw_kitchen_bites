class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:q].to_s.strip.downcase

    if @query.present?
      # Search users by username (case-insensitive)
      @users = User.where("LOWER(username) LIKE ?", "%#{@query}%")

      # Search recipes by title, description, ingredients, or category (case-insensitive)
      @recipes = Recipe.where(
        "LOWER(title) LIKE :q OR LOWER(description) LIKE :q OR LOWER(ingredients) LIKE :q OR LOWER(category) LIKE :q",
        q: "%#{@query}%"
      )
    else
      # No query, return empty results
      @users = User.none
      @recipes = Recipe.none
    end
  end
end
