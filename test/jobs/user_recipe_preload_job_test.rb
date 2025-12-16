class UserRecipePreloadJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    # Example: preload user's recipes to cache or prepare data
    user.recipes.load
  end
end
