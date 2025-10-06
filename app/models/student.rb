class Student < ApplicationRecord
  belongs_to :user
  has_many :notes, dependent: :destroy

  validates :name, presence: true
  validates :reading, :writing, :listening, :speaking,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  # Calculate scores automatically
  before_save :calculate_scores

  # Send notifications
  after_create :send_created_notification
  after_update :send_updated_notification

  private

  def calculate_scores
    self.total_score = reading + writing + listening + speaking
    self.percentage = (total_score / 40.0) * 100
  end

  def send_created_notification
    return unless user&.email.present?
    NotificationService.send_student_created_notification(self, user)
  end

  def send_updated_notification
    return unless user&.email.present?
    return unless saved_changes.any? # Only send if something actually changed
    NotificationService.send_student_updated_notification(self, user)
  end
end # rubocop:disable Layout/TrailingEmptyLines