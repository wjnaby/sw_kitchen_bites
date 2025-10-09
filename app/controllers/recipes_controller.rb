class RecipesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  # GET /recipes
  def index
    if user_signed_in?
      # ✅ Only show recipes created by the current user
      @recipes = Recipe
                    .where(user_id: current_user.id)
                    .includes(:user, images_attachments: :blob)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(10)
    else
      # For visitors (if you allow it), show all recipes
      @recipes = Recipe
                    .includes(:user, images_attachments: :blob)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(10)
    end

    # ✅ Redirect if the user is on an empty page
    if @recipes.empty? && params[:page].to_i > 1
      redirect_to recipes_path(page: @recipes.total_pages)
    end
  end

  # GET /recipes/:id
  def show
    @comment = Comment.new
    @comments = @recipe.comments
                       .includes(:user)
                       .order(created_at: :asc)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "recipe_#{@recipe.id}",
               template: "recipes/show.html.erb",
               layout: "pdf.html",
               page_size: 'A4',
               orientation: 'Portrait',
               encoding: "UTF-8"
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
      redirect_to recipes_path, notice: "Recipe successfully deleted."
    else
      redirect_to recipe_path(@recipe), alert: "Not authorized"
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :title,
      :description,
      :ingredients,
      :instructions,
      :cooking_time,
      :difficulty,
      :caption,
      :category,
      images: []
    )
  end

  def authorized?
    @recipe.user == current_user || current_user.admin?
  end
end
