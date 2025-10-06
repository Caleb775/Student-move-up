class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :message, null: false
      t.string :notification_type, null: false
      t.boolean :read, default: false, null: false

      t.timestamps
    end

    # user_id index is automatically created by t.references above
    add_index :notifications, :read
    add_index :notifications, :notification_type
  end
end
