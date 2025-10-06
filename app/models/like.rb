class Like < ApplicationRecord
  belongs_to :user
  belongs_to :recipe, counter_cache: true

  validates :user_id, uniqueness: { scope: :recipe_id }

  after_create :create_notification
  after_destroy :destroy_notification

  private

  def create_notification
    # don’t notify yourself if you like your own recipe
    return if recipe.user == user

    Notification.create(
      user: recipe.user,        # recipient = recipe owner
      actor: user,              # the one who liked
      notifiable: self,         # this Like record
      action: "liked",
      read: false
    )
  end

  def destroy_notification
    Notification.find_by(
      user: recipe.user,
      actor: user,
      notifiable: self
    )&.destroy
  end
end
