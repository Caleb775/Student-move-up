class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Add role-based access control
  # enum role: { student: 0, teacher: 1, admin: 2 }

  # Associations
  has_many :students, dependent: :destroy
  has_many :notes, dependent: :destroy

  # Validations
  validates :role, presence: true

  # Methods
  def admin?
    role == 2
  end

  def teacher?
    role == 1
  end

  def student?
    role == 0
  end
end # rubocop:disable Layout/TrailingEmptyLines