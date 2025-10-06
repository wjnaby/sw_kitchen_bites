module Admin
  class ReportedRecipesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_recipe, only: [:show, :edit, :update, :destroy]

    def index
      @reported_recipes = Recipe.joins(:reports)
                                .group('recipes.id')
                                .order('MAX(reports.created_at) DESC')
                                .limit(10)
    end

    def show
    end

    def edit
    end

    def update
      if @recipe.update(recipe_params)
        redirect_to admin_reported_recipes_path, notice: "Recipe updated successfully."
      else
        render :edit
      end
    end

    def destroy
      @recipe.destroy
      redirect_to admin_reported_recipes_path, notice: "Recipe deleted successfully."
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
