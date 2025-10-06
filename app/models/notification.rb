class Notification < ApplicationRecord
  belongs_to :user   # recipient
  belongs_to :actor, polymorphic: true  # FIX: polymorphic
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read: false) }

  def message
    case action
    when "liked"
      "#{actor.username} liked your recipe"
    when "commented"
      "#{actor.username} commented on your recipe"
    when "bookmarked"
      "#{actor.username} bookmarked your recipe"
    when "followed"
      "#{actor.username} followed you"
    else
      "You have a new notification"
    end
  end
end
