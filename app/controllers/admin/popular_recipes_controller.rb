module Admin
  class PopularRecipesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_recipe, only: [:show, :edit, :update, :destroy]

    def index
      @popular_recipes = Recipe.left_joins(:likes)
                               .group(:id)
                               .order('COUNT(likes.id) DESC')
                               .limit(10)
    end

    def show; end

    def edit; end

    def update
      if @recipe.update(recipe_params)
        redirect_to admin_popular_recipes_path, notice: "Recipe updated successfully."
      else
        render :edit
      end
    end

    def destroy
      @recipe.destroy
      redirect_to admin_popular_recipes_path, notice: "Recipe deleted successfully."
    end

    private

    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    def recipe_params
      params.require(:recipe).permit(:title, :description, :ingredients, :instructions, :image)
    end

    def require_admin
      redirect_to root_path, alert: "Access denied!" unless current_user&.admin?
    end
  end
end
