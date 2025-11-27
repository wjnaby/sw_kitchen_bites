# app/jobs/notification_broadcast_job.rb
class NotificationBroadcastJob
  include Sidekiq::Worker

  def perform(notification_id)
    notification = Notification.find(notification_id)

    # Broadcast a simple message to the user’s channel
    ActionCable.server.broadcast(
      "notifications_#{notification.user_id}_channel",
      message: "#{notification.actor.username} #{notification.action} your recipe!"
    )
  end
end
