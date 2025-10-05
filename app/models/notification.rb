class Notification < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :message, presence: true
  validates :notification_type, presence: true

  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }

  def mark_as_read!
    update!(read: true)
  end

  def unread?
    !read?
  end
end
