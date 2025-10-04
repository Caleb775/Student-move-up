class Note < ApplicationRecord
  belongs_to :student
  belongs_to :user, optional: true

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
end
