class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe

  def create
    @comment = @recipe.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      # ✅ Create notification when comment is saved
      create_notification(@comment)
      redirect_back(fallback_location: feed_path)
    else
      redirect_back(fallback_location: feed_path, alert: "Comment could not be saved.")
    end
  end

  def destroy
    @comment = @recipe.comments.find(params[:id])
    @comment.destroy
    # ✅ Remove notification when comment is deleted
    Notification.where(
      user: @recipe.user,
      actor: current_user,
      notifiable: @comment
    ).destroy_all
    redirect_back(fallback_location: feed_path)
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def create_notification(comment)
    return if @recipe.user == current_user # don’t notify yourself

    Notification.create(
      user: @recipe.user,   # recipient = recipe owner
      actor: current_user,  # the one who commented
      notifiable: comment,  # store comment as notifiable
      action: "commented",
      read: false
    )
  end
end
