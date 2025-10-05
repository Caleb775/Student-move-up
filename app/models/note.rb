class Note < ApplicationRecord
  belongs_to :student
  belongs_to :user, optional: true

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }

  # Send notifications
  after_create :send_note_notification

  private

  def send_note_notification
    # Send notification to the student's assigned teacher (if different from note creator)
    if student.user && student.user != user
      NotificationService.send_note_added_notification(self, student, student.user)
    end
  end
end # rubocop:disable Layout/TrailingEmptyLines