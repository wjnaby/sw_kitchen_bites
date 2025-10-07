class Recipe < ApplicationRecord
  # ---------------- Associations ----------------
  belongs_to :user

  # Multiple images with a limit
  has_many_attached :images
  validate :images_count_within_limit

  # Likes
  has_many :likes, dependent: :destroy
  has_many :liked_by_users, through: :likes, source: :user

  # Comments
  has_many :comments, dependent: :destroy

  # Bookmarks
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_by_users, through: :bookmarks, source: :user

  # Reports / Flagged recipes
  has_many :reports, dependent: :destroy
  scope :reported, -> { joins(:reports).distinct }

  # ---------------- Validations ----------------
  validates :title, :ingredients, :instructions, :cooking_time, presence: true

  # New Validations
  validates :caption, length: { maximum: 200 }, allow_blank: true  # ~30 words
  validates :category, inclusion: { in: ["food", "beverages"] }

  private

  # Limit number of images
  def images_count_within_limit
    if images.attached? && images.count > 5
      errors.add(:images, "You can attach up to 5 images only")
    end
  end
end
