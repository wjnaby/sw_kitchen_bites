# app/controllers/admin/dashboard_controller.rb
module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!      # Devise authentication
    before_action :require_admin           # Ensure only admins can access
    layout "application"

    # -------------------- Dashboard --------------------
    def index
      @users_count = User.count
      @recipes_count = Recipe.count
      @reports_count = Report.count

      @recent_users = User.order(created_at: :desc).limit(5)

      @popular_recipes = Recipe
                           .select('recipes.*, COUNT(likes.id) AS likes_count')
                           .left_joins(:likes)
                           .group('recipes.id')
                           .order('likes_count DESC')
                           .limit(5)

      @recent_reported_recipes = Report
                                   .includes(:recipe, :user)
                                   .order(created_at: :desc)
                                   .limit(5)
    end

    # -------------------- Active Users --------------------
    def active_users
      @active_users = User.order(created_at: :desc)
      render 'admin/active_users/index'
    end

    # -------------------- Popular Recipes --------------------
    def popular_recipes
      @popular_recipes = Recipe
                           .select('recipes.*, COUNT(likes.id) AS likes_count')
                           .left_joins(:likes)
                           .group('recipes.id')
                           .order('likes_count DESC')
                           .limit(20)
      render 'admin/popular_recipes/index'
    end

    # -------------------- Reported Recipes --------------------
    def reported_recipes
      @reported_recipes = Report
                            .includes(:recipe, :user)
                            .order(created_at: :desc)
                            .limit(20)
      render 'admin/reported_recipes/index'
    end

    private

    # -------------------- Admin check --------------------
    def require_admin
      redirect_to feed_path, alert: "Access denied." unless current_user.admin?
    end
  end
end
