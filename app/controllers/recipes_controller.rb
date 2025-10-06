class RecipesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  # GET /recipes
  def index
    # Eager load user and images efficiently
    @recipes = Recipe
      .includes(:user, images_attachments: :blob)  # avoid N+1 queries
      .order(created_at: :desc)
      .page(params[:page])                        # pagination
      .per(10)                                    # limit 10 per page
  end

  # GET /recipes/:id
  def show
    @comment = Comment.new
    @comments = @recipe.comments
                       .includes(:user)          # eager load comment authors
                       .order(created_at: :asc)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "recipe_#{@recipe.id}",             # PDF filename
               template: "recipes/show.html.erb",      # view template
               layout: "pdf.html",                     # optional PDF layout
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
      redirect_to feed_path, notice: "Recipe successfully deleted."
    else
      redirect_to recipe_path(@recipe), alert: "Not authorized"
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:title, :description, :ingredients, :instructions, :cooking_time, :difficulty, images: [])
  end

  def authorized?
    @recipe.user == current_user || current_user.admin?
  end
end
