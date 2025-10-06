class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # GET /notifications
  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  # GET /notifications/:id
  def show
    @notification = current_user.notifications.find(params[:id])
    # Automatically mark as read when viewed
    @notification.update(read: true) unless @notification.read?
  end
end
