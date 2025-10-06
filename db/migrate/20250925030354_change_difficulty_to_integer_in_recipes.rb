class ChangeDifficultyToStringInRecipes < ActiveRecord::Migration[6.1]
  def up
    change_column :recipes, :difficulty, :string
  end

  def down
    change_column :recipes, :difficulty, :integer
  end
end
