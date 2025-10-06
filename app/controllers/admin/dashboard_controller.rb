class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  # Dashboard overview
  def index
    @users_count = User.count
    @recipes_count = Recipe.count
    @reports_count = Recipe.joins(:reports).distinct.count  # reported recipes count

    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_recipes = Recipe.order(created_at: :desc).limit(5)
    @recent_reported_recipes = Recipe.joins(:reports).order('reports.created_at DESC').limit(5)
  end

  # All users page
  def all_users
    @users = User.order(created_at: :desc)
  end

  # All recipes page
  def all_recipes
    @recipes = Recipe.order(created_at: :desc)
  end

  # Reported recipes page
  def reported_recipes
    @reported_recipes = Recipe.joins(:reports).order('reports.created_at DESC')
  end

  # -------------------- Admin Actions --------------------

  # Toggle user active/inactive
  def toggle_user_active
    user = User.find(params[:id])
    user.update(active: !user.active)
    redirect_to admin_all_users_path, notice: "#{user.username} status updated."
  end

  # Delete a user
  def destroy_user
    user = User.find(params[:id])
    user.destroy
    redirect_to admin_all_users_path, notice: "User #{user.username} deleted."
  end

  # Delete a recipe
  def destroy_recipe
    recipe = Recipe.find(params[:id])
    recipe.destroy
    redirect_to admin_all_recipes_path, notice: "Recipe '#{recipe.title}' deleted."
  end

  # View a recipe (redirect to public recipe show page)
  def view_recipe
    recipe = Recipe.find(params[:id])
    redirect_to recipe_path(recipe)
  end

  private

  # Restrict access to admin users only
  def require_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
