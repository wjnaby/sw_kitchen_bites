class FeedsController < ApplicationController
  before_action :authenticate_user!

  def index
    followed_ids = current_user.following.pluck(:id)
    followed_ids = [0] if followed_ids.empty?  # dummy id to prevent SQL error

    @recipes = Recipe
      .includes(:user, images_attachments: :blob)
      .select("recipes.*, CASE WHEN user_id IN (#{followed_ids.join(',')}) THEN 1 ELSE 0 END AS followed_priority")
      .order("followed_priority DESC, created_at DESC")
  end
end
