class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:q].to_s.strip.downcase

    if @query.present?
      # Enqueue background job to cache search results
      SearchCacheJob.perform_later(current_user.id, @query)

      # Try to fetch cached results first
      cached = $redis.get("search:#{current_user.id}:#{@query}")
      if cached
        data = JSON.parse(cached)
        @users = User.where(id: data["user_ids"])
        @recipes = Recipe.where(id: data["recipe_ids"])
      else
        # Fallback: immediate search (first-time or cache miss)
        @users = User.where("LOWER(username) LIKE ?", "%#{@query}%")
        @recipes = Recipe.where(
          "LOWER(title) LIKE :q OR LOWER(description) LIKE :q OR LOWER(ingredients) LIKE :q OR LOWER(category) LIKE :q",
          q: "%#{@query}%"
        )
      end
    else
      # No query
      @users = User.none
      @recipes = Recipe.none
    end
  end
end
