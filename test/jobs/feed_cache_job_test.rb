class FeedCacheJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    followed_user_ids = Follow.where(follower_id: user.id).pluck(:followed_id)
    followed_user_ids = [-1] if followed_user_ids.empty?

    recipes = Recipe
      .includes(:user, images_attachments: :blob)
      .where.not(user_id: user.id)
      .select("recipes.*, 
               CASE WHEN user_id IN (#{followed_user_ids.join(',')}) THEN 1 ELSE 0 END AS followed_priority")
      .order(Arel.sql("followed_priority DESC, created_at DESC"))
      .limit(50) # Cache top 50 recipes

    # Store feed in Redis cache
    Redis.current.set("user_feed_#{user.id}", recipes.to_json, ex: 10.minutes) # expires in 10 min
  end
end
