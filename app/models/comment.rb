class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :recipe, counter_cache: true

  validates :body, presence: true

  # 👇 Add this
  has_many :notifications, as: :notifiable, dependent: :destroy
end
