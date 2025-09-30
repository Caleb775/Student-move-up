class Student < ApplicationRecord
  has_many :notes, dependent: :destroy

  validates :name, presence: true
  validates :reading, :writing, :listening, :speaking,
            presence: true,
            numericality: { in: 0..10 }
end
