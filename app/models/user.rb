class User < ApplicationRecord
  # ==========================
  # Devise Modules
  # ==========================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:username]

  # ==========================
  # Active Storage
  # ==========================
  has_one_attached :avatar

  # ==========================
  # Validations
  # ==========================
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true, inclusion: { in: %w[user admin] }

  # ==========================
  # Callbacks
  # ==========================
  after_initialize :set_default_role, if: :new_record?

  # ==========================
  # Roles Helper Methods
  # ==========================
  def admin?
    role == "admin"
  end

  def user?
    role == "user"
  end

  # ==========================
  # Associations
  # ==========================
  # Recipes
  has_many :recipes, dependent: :destroy

  has_many :notifications, dependent: :destroy

  # Likes
  has_many :likes, dependent: :destroy
  has_many :liked_recipes, through: :likes, source: :recipe

  # Comments
  has_many :comments, dependent: :destroy

  # Follows
  has_many :active_follows, class_name: 'Follow', foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :active_follows, source: :followed

  has_many :passive_follows, class_name: 'Follow', foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :passive_follows, source: :follower

  # Bookmarks
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_recipes, through: :bookmarks, source: :recipe

  # ==========================
  # Follow / Unfollow Helpers (Public)
  # ==========================
  def follow(user)
    following << user unless self == user || following.include?(user)
  end

  def unfollow(user)
    following.delete(user)
  end

  def following?(user)
    following.include?(user)
  end

  private

  # ==========================
  # Set Default Role
  # ==========================
  def set_default_role
    self.role ||= "user"
  end
end
