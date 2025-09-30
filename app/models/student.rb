# Student Model
#
# Represents a student in the language proficiency tracking system.
# Tracks scores across four language skills and calculates overall performance.
#
# == Schema Information
#
# Table name: students
#
#  id          :integer         not null, primary key
#  name        :string          not null
#  reading     :integer         not null (0-10)
#  writing     :integer         not null (0-10)
#  listening   :integer         not null (0-10)
#  speaking    :integer         not null (0-10)
#  total_score :integer         (calculated: sum of all skills)
#  percentage  :float           (calculated: total_score / 40 * 100)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#
# == Associations
#
# * has_many :notes - Student can have multiple notes (deleted when student is deleted)
#
# == Validations
#
# * name: must be present
# * reading, writing, listening, speaking: must be present and between 0-10
#
# == Calculated Fields
#
# * total_score: Sum of reading + writing + listening + speaking (max 40)
# * percentage: (total_score / 40.0) * 100
#
# Note: total_score and percentage are calculated in the controller before saving
#
# == Usage Examples
#
#   # Create a new student
#   student = Student.create(
#     name: "John Doe",
#     reading: 8,
#     writing: 7,
#     listening: 9,
#     speaking: 8
#   )
#   # => total_score: 32, percentage: 80.0
#
#   # Find top performing students
#   Student.order(percentage: :desc).limit(10)
#
#   # Get students with high performance
#   Student.where('percentage >= ?', 80)
#
#   # Access student's notes
#   student.notes.order(created_at: :desc)
#
class Student < ApplicationRecord
  # A student can have many notes. When a student is destroyed,
  # all associated notes are automatically deleted.
  has_many :notes, dependent: :destroy

  # Validates that the student's name is present and not blank
  validates :name, presence: true

  # Validates that all four language skill scores are present
  # and are numeric values between 0 and 10 (inclusive)
  validates :reading, :writing, :listening, :speaking,
            presence: true,
            numericality: { in: 0..10 }
end
