class SearchCacheJob < ApplicationJob
  queue_as :default

  def perform(user_id, query)
    query_downcase = query.to_s.strip.downcase

    users = User.where("LOWER(username) LIKE ?", "%#{query_downcase}%")
    recipes = Recipe.where(
      "LOWER(title) LIKE :q OR LOWER(description) LIKE :q OR LOWER(ingredients) LIKE :q OR LOWER(category) LIKE :q",
      q: "%#{query_downcase}%"
    )

    # Store only IDs in Redis for fast retrieval
    Redis.current.set(
      "search:#{user_id}:#{query_downcase}",
      { user_ids: users.pluck(:id), recipe_ids: recipes.pluck(:id) }.to_json,
      ex: 10.minutes # cache expires in 10 min
    )
  end
end
