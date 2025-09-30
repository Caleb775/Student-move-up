# Note Model
#
# Represents a note or comment about a student's performance, progress, or behavior.
# Each note is associated with a single student.
#
# == Schema Information
#
# Table name: notes
#
#  id         :integer         not null, primary key
#  content    :text            not null (1-1000 characters)
#  student_id :integer         not null, foreign key
#  created_at :datetime        not null
#  updated_at :datetime        not null
#
# == Associations
#
# * belongs_to :student - Each note belongs to exactly one student
#
# == Validations
#
# * content: must be present, minimum 1 character, maximum 1000 characters
#
# == Indexes
#
# * index_notes_on_student_id (student_id) - for faster lookups
#
# == Foreign Keys
#
# * student_id => students.id
#
# == Usage Examples
#
#   # Create a note for a student
#   student = Student.find(1)
#   note = student.notes.create(content: "Excellent progress in speaking")
#
#   # Find recent notes for a student
#   student.notes.order(created_at: :desc).limit(5)
#
#   # Update a note
#   note.update(content: "Outstanding improvement in all areas")
#
#   # Search notes by content
#   student.notes.where('content ILIKE ?', '%improvement%')
#
class Note < ApplicationRecord
  # Each note belongs to a student. The student_id foreign key is required.
  belongs_to :student

  # Validates that content is present and within the acceptable length range
  # - Must not be empty
  # - Must be at least 1 character
  # - Must not exceed 1000 characters
  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
end
