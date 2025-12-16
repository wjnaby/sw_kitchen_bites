# app/jobs/send_follow_notification_job.rb
class SendFollowNotificationJob < ApplicationJob
  queue_as :default

  def perform(follower_id, followed_id)
    follower = User.find(follower_id)
    followed = User.find(followed_id)

    # Example: send email
    FollowMailer.with(follower: follower, followed: followed).new_follower_email.deliver_now

    # Or push notification logic
  end
end
