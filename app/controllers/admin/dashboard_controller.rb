module Admin
  class DashboardController < ApplicationController
    layout "application"   # <--- use your main application layout

    before_action :authenticate_user!
    before_action :require_admin

    def index
      @users_count = User.count
      @recipes_count = Recipe.count
      @reports_count = Report.count

      @recent_users = User.order(created_at: :desc).limit(5)
      @popular_recipes = Recipe.left_joins(:likes)
                               .group(:id)
                               .order('COUNT(likes.id) DESC')
                               .limit(5)
      @recent_reported_recipes = Recipe.joins(:reports)
                                       .group('recipes.id')
                                       .order('MAX(reports.created_at) DESC')
                                       .limit(5)
    end

    private

    def require_admin
      redirect_to root_path, alert: "Access denied!" unless current_user&.admin?
    end
  end
end
