class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validates :follower_id, uniqueness: { scope: :followed_id }

  # 👇 Add this
  has_many :notifications, as: :notifiable, dependent: :destroy
end
