# app/channels/admin_dashboard_channel.rb
class AdminDashboardChannel < ApplicationCable::Channel
  def subscribed
    stream_from "admin_dashboard_channel"
  end
end
