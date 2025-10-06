class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :follow, :unfollow]

  def show
    @recipes = @user.recipes
    @followers_count = @user.followers.count
    @following_count = @user.following.count
  end

  def edit
    redirect_to root_path, alert: "Not authorized" unless current_user == @user
  end

  def update
    if current_user == @user
      if @user.update(user_params)
        redirect_to user_path(@user.username), notice: "Profile updated successfully."
      else
        render :edit
      end
    else
      redirect_to root_path, alert: "Not authorized"
    end
  end

  def follow
    current_user.follow(@user) unless current_user == @user
    redirect_to user_path(@user.username)
  end

  def unfollow
    current_user.unfollow(@user) unless current_user == @user
    redirect_to user_path(@user.username)
  end

  private

  def set_user
    @user = User.find_by!(username: params[:username])
  end

  def user_params
    params.require(:user).permit(:username, :email, :avatar, :bio)
  end
end
