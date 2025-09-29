# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Student.create(name: "Alice", reading: 9, writing: 8, listening: 10, speaking: 7)
Student.create(name: "Bob", reading: 7, writing: 6, listening: 8, speaking: 9)
Student.create(name: "Charlie", reading: 10, writing: 9, listening: 10, speaking: 10)
