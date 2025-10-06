module Admin
  class ActiveUsersController < ApplicationController
    before_action :require_admin
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @active_users = User.joins(:recipes).distinct
    end

    def show; end

    def edit; end

    def update
      if @user.update(user_params)
        redirect_to admin_active_users_path, notice: "User updated successfully."
      else
        render :edit
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_active_users_path, notice: "User deleted successfully."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:username, :email, :role, :bio, :avatar)
    end

    def require_admin
      redirect_to root_path, alert: "Access denied!" unless current_user&.admin?
    end
  end
end
