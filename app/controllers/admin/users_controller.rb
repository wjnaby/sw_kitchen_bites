module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_user, only: [:edit, :update, :destroy]

    # Admin Dashboard - list users and recipes
    def index
      # Counts for dashboard
      @users_count = User.count
      @recipes_count = Recipe.count

      # All users, newest first
      @users = User.all.order(created_at: :desc)

      # Active users (users with at least 1 recipe)
      @active_users = User.joins(:recipes).distinct

      # Popular recipes (top 5 by likes)
      @popular_recipes = Recipe.left_joins(:likes)
                               .group(:id)
                               .order('COUNT(likes.id) DESC')
                               .limit(5)

      # Recently reported recipes (top 5 recent reports)
      @reported_recipes = Recipe.joins(:reports)
                                .group('recipes.id')
                                .order('MAX(reports.created_at) DESC')
                                .limit(5)
    end

    # Edit user
    def edit
    end

    # Update user
    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User updated successfully."
      else
        flash.now[:alert] = "Failed to update user."
        render :edit, status: :unprocessable_entity
      end
    end

    # Delete user
    def destroy
      if @user.destroy
        redirect_to admin_users_path, notice: "User deleted successfully."
      else
        redirect_to admin_users_path, alert: "Failed to delete user."
      end
    end

    private

    # Strong params
    def user_params
      params.require(:user).permit(:username, :email, :role, :bio, :avatar)
    end

    # Set user for edit/update/destroy
    def set_user
      @user = User.find_by(id: params[:id])
      redirect_to admin_users_path, alert: "User not found." unless @user
    end

    # Admin access check
    def require_admin
      redirect_to root_path, alert: "Access denied!" unless current_user&.admin?
    end
  end
end
