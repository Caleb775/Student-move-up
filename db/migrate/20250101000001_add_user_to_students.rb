class AddUserToStudents < ActiveRecord::Migration[8.0]
  def change
    add_reference :students, :user, null: true, foreign_key: true
  end
end # rubocop:disable Layout/TrailingEmptyLines