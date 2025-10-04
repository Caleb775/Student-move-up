# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user
admin_user = User.find_or_create_by(email: 'admin@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = 2  # admin
  user.first_name = 'Admin'
  user.last_name = 'User'
end
admin_user.update!(role: 2) # Force update role

# Create teacher user
teacher_user = User.find_or_create_by(email: 'teacher@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = 1  # teacher
  user.first_name = 'Teacher'
  user.last_name = 'User'
end
teacher_user.update!(role: 1) # Force update role

# Create student user
student_user = User.find_or_create_by(email: 'student@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = 0  # student
  user.first_name = 'Student'
  user.last_name = 'User'
end
student_user.update!(role: 0) # Force update role

# Create sample students
Student.create(name: "Alice", reading: 9, writing: 8, listening: 10, speaking: 7)
Student.create(name: "Bob", reading: 7, writing: 6, listening: 8, speaking: 9)
Student.create(name: "Charlie", reading: 10, writing: 9, listening: 10, speaking: 10) # rubocop:disable Layout/TrailingEmptyLines