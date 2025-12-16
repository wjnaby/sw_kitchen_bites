class BookmarkNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, recipe_id)
    user = User.find(user_id)
    recipe = Recipe.find(recipe_id)

    # Example: send email to recipe owner
    RecipeMailer.with(user: user, recipe: recipe)
                .bookmark_notification_email
                .deliver_now

    # Optional: log analytics
    BookmarkAnalytics.create(user: user, recipe: recipe, action: "bookmarked")
  end
end
