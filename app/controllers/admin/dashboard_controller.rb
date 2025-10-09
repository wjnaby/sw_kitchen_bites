# app/controllers/admin/dashboard_controller.rb
module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    layout "application"

    # -------------------- Dashboard Overview --------------------
    def index
      # Stats
      @users_count = User.count
      @recipes_count = Recipe.count
      @reports_count = Report.count

      # Recent activity
      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_recipes = Recipe.order(created_at: :desc).limit(5)
      @recent_reported_recipes = Report.includes(:recipe, :user).order(created_at: :desc).limit(5)

      # Most Active Users (by recipe count)
      @most_active_users = User.joins(:recipes)
                               .select('users.*, COUNT(recipes.id) AS recipes_count')
                               .group('users.id')
                               .order('recipes_count DESC')
                               .limit(5)

      # Most Liked Recipes
      @most_liked_recipes = Recipe.left_joins(:likes)
                                  .select('recipes.*, COUNT(likes.id) AS likes_count')
                                  .group('recipes.id')
                                  .order('likes_count DESC')
                                  .limit(5)
    end

    # -------------------- All Users Page --------------------
    def all_users
      @users = User.order(created_at: :desc).page(params[:page]).per(10)
    end

    # -------------------- All Recipes Page --------------------
    def all_recipes
      # All Recipes (for "All" tab)
      @recipes = Recipe.includes(:user)
                       .order(created_at: :desc)
                       .page(params[:page])
                       .per(10)

      # Food Recipes (for "Food" tab)
      @food_recipes = Recipe.includes(:user)
                            .where("LOWER(category) = ?", "food")
                            .order(created_at: :desc)
                            .page(params[:food_page])
                            .per(10)

      # Beverages Recipes (for "Beverages" tab)
      @beverage_recipes = Recipe.includes(:user)
                                .where("LOWER(category) IN (?)", ["beverage", "beverages"])
                                .order(created_at: :desc)
                                .page(params[:beverage_page])
                                .per(10)

      # Ensure none are nil
      @recipes ||= Recipe.none
      @food_recipes ||= Recipe.none
      @beverage_recipes ||= Recipe.none

      render 'admin/dashboard/all_recipes'
    end

    # -------------------- Reported Recipes Page --------------------
    def reported_recipes
      # ✅ FIX: MySQL-safe version (no DISTINCT + ORDER)
      @reported_recipes = Recipe
        .joins(:reports)
        .select('recipes.*, MAX(reports.created_at) AS last_reported_at, COUNT(reports.id) AS reports_count')
        .group('recipes.id')
        .order('last_reported_at DESC')
        .page(params[:page])
        .per(10)
    end

    # -------------------- Admin Actions --------------------
    def toggle_user_active
      user = User.find(params[:id])
      user.update(active: !user.active)
      redirect_to admin_all_users_path, notice: "#{user.username}'s status updated successfully."
    end

    def destroy_user
      user = User.find(params[:id])
      username = user.username
      user.destroy
      redirect_to admin_all_users_path, notice: "User #{username} has been deleted successfully."
    end

    def destroy_recipe
      recipe = Recipe.find(params[:id])
      title = recipe.title
      recipe.destroy
      redirect_to admin_all_recipes_path, notice: "Recipe '#{title}' deleted successfully."
    end

    # -------------------- View Recipe --------------------
    def view_recipe
      @recipe = Recipe.find(params[:id])
      render "admin/dashboard/view_recipe"
    end

    private

    # -------------------- Restrict Access --------------------
    def require_admin!
      unless current_user.admin?
        redirect_to root_path, alert: "You are not authorized to access this page."
      end
    end
  end
end
