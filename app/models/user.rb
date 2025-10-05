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
  has_many :notifications, dependent: :destroy

  # Validations
  validates :role, presence: true

  # Generate API token before creation
  before_create :generate_api_token

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

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def role_name
    case role
    when 0
      "Student"
    when 1
      "Teacher"
    when 2
      "Admin"
    else
      "Unknown"
    end
  end

  def regenerate_api_token!
    generate_api_token
    save!
  end

  # Ransack searchable attributes - only safe, non-sensitive fields
  def self.ransackable_attributes(auth_object = nil)
    %w[created_at email first_name id last_name role updated_at]
  end

  # Ransack searchable associations - only safe associations
  def self.ransackable_associations(auth_object = nil)
    %w[students notes notifications]
  end

  private

  def generate_api_token
    loop do
      self.api_token = SecureRandom.hex(32)
      break unless User.exists?(api_token: api_token)
    end
  end
end # rubocop:disable Layout/TrailingEmptyLines