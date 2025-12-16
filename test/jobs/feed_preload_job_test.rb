class FeedPreloadJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    followed_user_ids = Follow.where(follower_id: user_id).pluck(:followed_id)
    followed_user_ids = [-1] if followed_user_ids.empty?

    Recipe
      .includes(:user, images_attachments: :blob)
      .where.not(user_id: user_id)
      .where(user_id: followed_user_ids)
      .limit(50)
      .load
  end
end
