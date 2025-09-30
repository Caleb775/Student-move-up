class Note < ApplicationRecord
  belongs_to :student

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
end
