module Admin
  class ReportedRecipesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_recipe, only: [:show, :edit, :update, :destroy]

    # ===========================
    # GET /admin/reported_recipes
    # ===========================
    def index
      @reported_recipes = Recipe
        .joins(:reports)
        .select('recipes.*, MAX(reports.created_at) AS last_reported_at, COUNT(reports.id) AS reports_count')
        .group('recipes.id')
        .order('last_reported_at DESC')
        .limit(10)
    end

    # ===========================
    # GET /admin/reported_recipes/:id
    # ===========================
    def show
    end

    # ===========================
    # GET /admin/reported_recipes/:id/edit
    # ===========================
    def edit
    end

    # ===========================
    # PATCH/PUT /admin/reported_recipes/:id
    # ===========================
    def update
      if @recipe.update(recipe_params)
        redirect_to admin_reported_recipes_path, notice: "✅ Recipe updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # ===========================
    # DELETE /admin/reported_recipes/:id
    # ===========================
    def destroy
      @recipe.destroy
      redirect_to admin_reported_recipes_path, notice: "🗑️ Recipe deleted successfully."
    end

    private

    # ---------------------------
    # Callbacks
    # ---------------------------
    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    def recipe_params
      params.require(:recipe).permit(:title, :description, :ingredients, :instructions, :image)
    end

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: "⚠️ Access denied!"
      end
    end
  end
end
