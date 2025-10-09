class FeedsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Get IDs of users that the current user follows
    followed_user_ids = Follow.where(follower_id: current_user.id).pluck(:followed_id)
    followed_user_ids = [-1] if followed_user_ids.empty?

    @recipes = Recipe
      .includes(:user, images_attachments: :blob)  # eager load associations
      .where.not(user_id: current_user.id)         # exclude current user's posts
      .select("recipes.*, 
               CASE WHEN user_id IN (#{followed_user_ids.join(',')}) THEN 1 ELSE 0 END AS followed_priority")
      .order(Arel.sql("followed_priority DESC, RAND()"))  # ✅ followed first, then random within groups
      .page(params[:page])
      .per(10)
  end
end
