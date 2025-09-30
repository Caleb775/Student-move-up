## Database schema

The app uses PostgreSQL. Key tables are `students` and `notes`.

```ruby
# Extract from db/schema.rb
ActiveRecord::Schema[8.0].define(version: 2025_09_30_214140) do
  enable_extension "pg_catalog.plpgsql"

  create_table "notes", force: :cascade do |t|
    t.text "content"
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_notes_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.integer "reading"
    t.integer "writing"
    t.integer "listening"
    t.integer "speaking"
    t.integer "total_score"
    t.float "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "notes", "students"
end
```

### Notes

- `total_score` and `percentage` are calculated in the web layer during create/update of a student.
- `notes.student_id` has a foreign key to `students.id`.
