# Models Documentation

## Overview

This document provides comprehensive documentation for all ActiveRecord models in the Student Management System.

## Student Model

**File:** `app/models/student.rb`

### Description

The Student model represents a student in the language learning system. It tracks proficiency scores across four language skills and automatically calculates total scores and percentages.

### Attributes

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| `id` | Integer | Primary key, auto-generated | Unique, not null |
| `name` | String | Student's full name | Required, not null |
| `reading` | Integer | Reading proficiency score | Required, 0-10 range |
| `writing` | Integer | Writing proficiency score | Required, 0-10 range |
| `listening` | Integer | Listening proficiency score | Required, 0-10 range |
| `speaking` | Integer | Speaking proficiency score | Required, 0-10 range |
| `total_score` | Integer | Sum of all skill scores | Auto-calculated, 0-40 range |
| `percentage` | Float | Percentage score out of 100 | Auto-calculated, 0.0-100.0 range |
| `created_at` | DateTime | Record creation timestamp | Auto-generated |
| `updated_at` | DateTime | Last update timestamp | Auto-updated |

### Validations

```ruby
validates :name, presence: true
validates :reading, :writing, :listening, :speaking,
          presence: true,
          numericality: { in: 0..10 }
```

**Validation Rules:**
- `name`: Must be present (cannot be blank or nil)
- `reading`: Must be present and a number between 0 and 10 (inclusive)
- `writing`: Must be present and a number between 0 and 10 (inclusive)
- `listening`: Must be present and a number between 0 and 10 (inclusive)
- `speaking`: Must be present and a number between 0 and 10 (inclusive)

### Associations

```ruby
has_many :notes, dependent: :destroy
```

**Relationships:**
- **Notes**: A student can have many notes. When a student is deleted, all associated notes are automatically deleted (`dependent: :destroy`).

### Callbacks

The model uses controller-level callbacks for score calculation:
- `total_score` is calculated as the sum of reading, writing, listening, and speaking scores
- `percentage` is calculated as `(total_score / 40.0) * 100`

### Class Methods

Currently, no custom class methods are defined.

### Instance Methods

Currently, no custom instance methods are defined. Score calculations are handled in the controller.

### Usage Examples

#### Creating a Student

```ruby
# Valid student creation
student = Student.new(
  name: "John Doe",
  reading: 8,
  writing: 7,
  listening: 9,
  speaking: 8
)

if student.valid?
  # Scores would be calculated in controller before saving
  student.save
  puts "Student created with #{student.percentage}% score"
else
  puts student.errors.full_messages
end
```

#### Querying Students

```ruby
# Find all students ordered by percentage (highest first)
top_students = Student.order(percentage: :desc)

# Find students with high scores (>= 80%)
high_performers = Student.where('percentage >= ?', 80.0)

# Find student by name
student = Student.find_by(name: "John Doe")
```

#### Updating a Student

```ruby
student = Student.find(1)
student.update(
  reading: 9,
  writing: 8
)
# Note: total_score and percentage would be recalculated in controller
```

---

## Note Model

**File:** `app/models/note.rb`

### Description

The Note model represents textual notes or comments associated with a student. These can be used for tracking progress, observations, or any relevant information about the student.

### Attributes

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| `id` | Integer | Primary key, auto-generated | Unique, not null |
| `content` | Text | Note content/body | Required, 1-1000 characters |
| `student_id` | Integer | Foreign key to student | Required, not null |
| `created_at` | DateTime | Record creation timestamp | Auto-generated |
| `updated_at` | DateTime | Last update timestamp | Auto-updated |

### Validations

```ruby
validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
```

**Validation Rules:**
- `content`: Must be present and between 1 and 1000 characters in length

### Associations

```ruby
belongs_to :student
```

**Relationships:**
- **Student**: Each note belongs to exactly one student. The student must exist (enforced by foreign key constraint).

### Callbacks

Currently, no custom callbacks are defined.

### Class Methods

Currently, no custom class methods are defined.

### Instance Methods

Currently, no custom instance methods are defined.

### Usage Examples

#### Creating a Note

```ruby
# Find the student first
student = Student.find(1)

# Create a note for the student
note = student.notes.build(
  content: "Student shows excellent progress in speaking skills."
)

if note.save
  puts "Note created successfully"
else
  puts note.errors.full_messages
end

# Alternative creation method
note = Note.create(
  content: "Needs improvement in listening comprehension.",
  student_id: 1
)
```

#### Querying Notes

```ruby
# Get all notes for a student (ordered by creation date, newest first)
student_notes = Note.where(student_id: 1).order(created_at: :desc)

# Get recent notes (last 7 days)
recent_notes = Note.where('created_at >= ?', 7.days.ago)

# Search notes by content
notes_with_keyword = Note.where('content ILIKE ?', '%progress%')
```

#### Updating a Note

```ruby
note = Note.find(1)
note.update(content: "Updated note content with new observations.")
```

#### Deleting a Note

```ruby
note = Note.find(1)
note.destroy
```

---

## Database Schema

### Students Table

```sql
CREATE TABLE students (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR,
  reading INTEGER,
  writing INTEGER,
  listening INTEGER,
  speaking INTEGER,
  total_score INTEGER,
  percentage FLOAT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

### Notes Table

```sql
CREATE TABLE notes (
  id BIGSERIAL PRIMARY KEY,
  content TEXT,
  student_id BIGINT NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  CONSTRAINT fk_notes_student_id FOREIGN KEY (student_id) REFERENCES students(id)
);

CREATE INDEX index_notes_on_student_id ON notes(student_id);
```

## Model Relationships Diagram

```
Student (1) ----< Notes (many)
  |
  ├── id (PK)
  ├── name
  ├── reading
  ├── writing
  ├── listening
  ├── speaking
  ├── total_score
  ├── percentage
  ├── created_at
  └── updated_at

Note
  ├── id (PK)
  ├── content
  ├── student_id (FK)
  ├── created_at
  └── updated_at
```

## Best Practices

### When Working with Students

1. **Always validate scores**: Ensure all skill scores are within the 0-10 range
2. **Calculate scores consistently**: Use the controller's `calculate_scores` method to ensure `total_score` and `percentage` are accurate
3. **Handle deletions carefully**: Remember that deleting a student will also delete all associated notes

### When Working with Notes

1. **Keep content concise**: While the limit is 1000 characters, shorter notes are often more effective
2. **Use meaningful content**: Notes should provide valuable information about the student's progress or status
3. **Consider chronological order**: Notes are typically displayed newest first, so structure content accordingly

### Performance Considerations

1. **Indexing**: The `student_id` foreign key in notes is indexed for efficient queries
2. **Eager loading**: When displaying students with their notes, use `includes(:notes)` to avoid N+1 queries
3. **Ordering**: Default ordering by percentage for students and creation date for notes is optimized for common use cases