# app/jobs/dashboard_admin_job.rb
class DashboardAdminJob
  include Sidekiq::Worker

  def perform
    stats = {
      users_count: User.count,
      recipes_count: Recipe.count,
      likes_count: Like.count
    }

    # Example: broadcast to admin dashboard
    ActionCable.server.broadcast(
      "admin_dashboard_channel",
      stats: stats
    )
  end
end
