class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  # -------------------- Dashboard Overview --------------------
  def index
    @users_count = User.count
    @recipes_count = Recipe.count
    @reports_count = Recipe.joins(:reports).distinct.count

    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_recipes = Recipe.order(created_at: :desc).limit(5)
    @recent_reported_recipes = Recipe.joins(:reports).order('reports.created_at DESC').limit(5)
  end

  # -------------------- All Users Page --------------------
  def all_users
    @users = User.order(created_at: :desc).page(params[:page]).per(10)
  end

  # -------------------- All Recipes Page --------------------
  def all_recipes
    @recipes = Recipe.order(created_at: :desc).page(params[:page]).per(10)
  end

  # -------------------- Reported Recipes Page --------------------
  def reported_recipes
    @reported_recipes = Recipe.joins(:reports)
                              .order('reports.created_at DESC')
                              .distinct
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

  # ✅ FIXED: Proper admin-side view to prevent routing error
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
