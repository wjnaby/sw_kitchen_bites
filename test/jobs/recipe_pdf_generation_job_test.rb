class RecipePdfJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    pdf = WickedPdf.new.pdf_from_string(
      ApplicationController.render(
        template: 'recipes/show.html.erb',
        layout: 'pdf.html',
        locals: { recipe: recipe }
      )
    )
    # Save PDF to storage or send email
    File.write(Rails.root.join("public/pdfs/recipe_#{recipe.id}.pdf"), pdf)
  end
end
