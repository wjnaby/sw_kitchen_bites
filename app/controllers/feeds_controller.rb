class FeedsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Enqueue background job to refresh the feed cache
    FeedCacheJob.perform_later(current_user.id)

    # Try fetching cached feed from Redis
    cached_feed = $redis.get("user_feed_#{current_user.id}")
    if cached_feed
      # Load cached recipe IDs and fetch full records
      recipe_ids = JSON.parse(cached_feed)
      @recipes = Recipe.includes(:user, images_attachments: :blob)
                       .where(id: recipe_ids)
                       .order(Arel.sql("FIELD(id, #{recipe_ids.join(',')})"))
                       .page(params[:page])
                       .per(10)
    else
      # Fallback: load feed for first-time or cache miss
      followed_user_ids = Follow.where(follower_id: current_user.id).pluck(:followed_id)
      followed_user_ids = [-1] if followed_user_ids.empty?

      @recipes = Recipe.includes(:user, images_attachments: :blob)
                       .where.not(user_id: current_user.id)
                       .select("recipes.*, 
                                CASE WHEN user_id IN (#{followed_user_ids.join(',')}) THEN 1 ELSE 0 END AS followed_priority")
                       .order(Arel.sql("followed_priority DESC, created_at DESC"))
                       .page(params[:page])
                       .per(10)
    end
  end
end
