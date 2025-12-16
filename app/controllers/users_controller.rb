class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :follow, :unfollow]

  # Show user profile
  def show
    # Preload recipes asynchronously to speed up the request
    UserRecipePreloadJob.perform_later(@user.id)

    @recipes = @user.recipes
    @followers_count = @user.followers.count
    @following_count = @user.following.count
  end

  # Edit profile (only owner)
  def edit
    redirect_to root_path, alert: "Not authorized" unless current_user == @user
  end

  # Update profile
  def update
    if current_user == @user
      if @user.update(user_params)
        # Log profile update asynchronously
        ProfileUpdateLogJob.perform_later(@user.id, current_user.id)

        redirect_to user_path(@user.username), notice: "Profile updated successfully."
      else
        render :edit
      end
    else
      redirect_to root_path, alert: "Not authorized"
    end
  end

  # Follow another user
  def follow
    if current_user != @user
      current_user.follow(@user)

      # Send follow notification in the background
      SendFollowNotificationJob.perform_later(current_user.id, @user.id)
    end
    redirect_to user_path(@user.username)
  end

  # Unfollow a user
  def unfollow
    current_user.unfollow(@user) if current_user != @user
    redirect_to user_path(@user.username)
  end

  private

  # Find user by username
  def set_user
    @user = User.find_by!(username: params[:username])
  end

  # Strong params for user update
  def user_params
    params.require(:user).permit(:username, :email, :avatar, :bio)
  end
end
