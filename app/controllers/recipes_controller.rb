class RecipesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :delete_image]

  # GET /recipes
  def index
    if user_signed_in?
      @recipes = Recipe.where(user_id: current_user.id)
                       .includes(:user, images_attachments: :blob)
                       .order(created_at: :desc)
                       .page(params[:page])
                       .per(10)
    else
      @recipes = Recipe.includes(:user, images_attachments: :blob)
                       .order(created_at: :desc)
                       .page(params[:page])
                       .per(10)
    end

    # Redirect if page is empty
    redirect_to recipes_path(page: @recipes.total_pages) if @recipes.empty? && params[:page].to_i > 1
  end

  # GET /recipes/:id
  def show
    @comment = Comment.new
    @comments = @recipe.comments.includes(:user).order(created_at: :asc)

    respond_to do |format|
      format.html
      format.pdf do
        # Generate PDF asynchronously
        RecipePdfJob.perform_later(@recipe.id)
        redirect_to recipe_path(@recipe), notice: "PDF generation started. You will be notified when ready."
      end
    end
  end

  # GET /recipes/new
  def new
    @recipe = current_user.recipes.build
  end

  # POST /recipes
  def create
    @recipe = current_user.recipes.build(recipe_params)
    if @recipe.save
      # Enqueue background jobs
      RecipeNotificationJob.perform_later(@recipe.id)
      FeedCacheJob.perform_later(current_user.id) # refresh feed cache

      redirect_to recipe_path(@recipe), notice: "Recipe successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /recipes/:id/edit
  def edit
    redirect_to recipe_path(@recipe), alert: "Not authorized" unless authorized?
  end

  # PATCH/PUT /recipes/:id
  def update
    if authorized?
      if @recipe.update(recipe_params)
        # Enqueue jobs for notifications and feed cache refresh
        RecipeNotificationJob.perform_later(@recipe.id)
        FeedCacheJob.perform_later(current_user.id)

        redirect_to recipe_path(@recipe), notice: "Recipe successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to recipe_path(@recipe), alert: "Not authorized"
    end
  end

  # DELETE /recipes/:id
  def destroy
    if authorized?
      @recipe.destroy
      FeedCacheJob.perform_later(current_user.id) # refresh feed cache
      redirect_to recipes_path, notice: "Recipe successfully deleted."
    else
      redirect_to recipe_path(@recipe), alert: "Not authorized"
    end
  end

  # DELETE /recipes/:id/delete_image
  def delete_image
    unless authorized?
      redirect_to recipe_path(@recipe), alert: "Not authorized" and return
    end

    image = @recipe.images.find_by(id: params[:image_id])
    
    if image
      image.purge
      redirect_to edit_recipe_path(@recipe), notice: "Image deleted successfully."
    else
      redirect_to edit_recipe_path(@recipe), alert: "Image not found."
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :title, :description, :ingredients, :instructions,
      :cooking_time, :difficulty, :caption, :category,
      images: []
    )
  end

  def authorized?
    @recipe.user == current_user || current_user.admin?
  end
end