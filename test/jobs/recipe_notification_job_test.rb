class RecipeNotificationJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    followers = recipe.user.followers

    followers.each do |follower|
      RecipeMailer.with(user: follower, recipe: recipe)
                  .new_recipe_email
                  .deliver_now
    end
  end
end
