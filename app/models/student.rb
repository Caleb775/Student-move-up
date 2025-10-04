class Student < ApplicationRecord
  belongs_to :user, optional: true
  has_many :notes, dependent: :destroy

  validates :name, presence: true
  validates :reading, :writing, :listening, :speaking,
            presence: true,
            numericality: { in: 0..10 }

  # Calculate scores automatically
  before_save :calculate_scores

  private

  def calculate_scores
    self.total_score = reading + writing + listening + speaking
    self.percentage = (total_score / 40.0) * 100
  end
end
