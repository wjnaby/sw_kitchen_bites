class Recipe < ApplicationRecord
  belongs_to :user

  # Multiple images with limit
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

  # Validations
  validates :title, :ingredients, :instructions, :cooking_time, presence: true

  private

  def images_count_within_limit
    if images.attached? && images.count > 5
      errors.add(:images, "You can attach up to 5 images only")
    end
  end

  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Reports
  has_many :reports, dependent: :destroy

  # Flagged recipes
  scope :reported, -> { joins(:reports).distinct }
end
