class AddUserToNotes < ActiveRecord::Migration[8.0]
  def change
    # First add the column as nullable
    add_reference :notes, :user, null: true, foreign_key: true

    # Update existing notes to have a default user (admin)
    admin_user = User.find_by(email: 'admin@example.com')
    if admin_user
      Note.where(user_id: nil).update_all(user_id: admin_user.id)
    end

    # Now make the column non-nullable
    change_column_null :notes, :user_id, false
  end
end # rubocop:disable Layout/TrailingEmptyLines