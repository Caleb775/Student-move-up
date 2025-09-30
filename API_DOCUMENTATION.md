# API Documentation

## Table of Contents

1. [Overview](#overview)
2. [Models](#models)
   - [Student Model](#student-model)
   - [Note Model](#note-model)
3. [Controllers & Routes](#controllers--routes)
   - [Students Controller](#students-controller)
   - [Notes Controller](#notes-controller)
4. [JavaScript Components](#javascript-components)
5. [API Examples](#api-examples)
6. [Error Handling](#error-handling)

---

## Overview

This is a Rails 8.0.3 application for managing student language proficiency scores and associated notes. The application tracks student performance across four language skills: reading, writing, listening, and speaking.

### Technology Stack

- **Framework**: Ruby on Rails 8.0.3
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Asset Pipeline**: Propshaft
- **Server**: Puma

---

## Models

### Student Model

The Student model represents a student with language proficiency scores.

#### Attributes

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| `id` | Integer | Primary key | Auto-generated |
| `name` | String | Student's name | Required |
| `reading` | Integer | Reading score (0-10) | Required, 0-10 |
| `writing` | Integer | Writing score (0-10) | Required, 0-10 |
| `listening` | Integer | Listening score (0-10) | Required, 0-10 |
| `speaking` | Integer | Speaking score (0-10) | Required, 0-10 |
| `total_score` | Integer | Sum of all scores | Auto-calculated |
| `percentage` | Float | Percentage score | Auto-calculated |
| `created_at` | DateTime | Creation timestamp | Auto-generated |
| `updated_at` | DateTime | Last update timestamp | Auto-generated |

#### Associations

- `has_many :notes, dependent: :destroy` - A student can have multiple notes. When a student is deleted, all associated notes are also deleted.

#### Validations

```ruby
validates :name, presence: true
validates :reading, :writing, :listening, :speaking,
          presence: true,
          numericality: { in: 0..10 }
```

#### Calculated Fields

- **total_score**: Sum of reading + writing + listening + speaking scores (max 40)
- **percentage**: (total_score / 40.0) * 100

#### Example Usage

```ruby
# Create a new student
student = Student.new(
  name: "John Doe",
  reading: 8,
  writing: 7,
  listening: 9,
  speaking: 8
)
student.save
# total_score will be 32, percentage will be 80.0

# Find a student
student = Student.find(1)

# Update a student
student.update(reading: 9)
# total_score and percentage are automatically recalculated

# Get all notes for a student
student.notes
```

---

### Note Model

The Note model represents notes associated with a student.

#### Attributes

| Attribute | Type | Description | Constraints |
|-----------|------|-------------|-------------|
| `id` | Integer | Primary key | Auto-generated |
| `content` | Text | Note content | Required, 1-1000 chars |
| `student_id` | Integer | Foreign key to student | Required |
| `created_at` | DateTime | Creation timestamp | Auto-generated |
| `updated_at` | DateTime | Last update timestamp | Auto-generated |

#### Associations

- `belongs_to :student` - Each note belongs to a single student

#### Validations

```ruby
validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
```

#### Example Usage

```ruby
# Create a note for a student
student = Student.find(1)
note = student.notes.create(content: "Excellent progress in speaking")

# Find a note
note = Note.find(1)

# Access the student from a note
note.student

# Update a note
note.update(content: "Outstanding improvement in all areas")

# Delete a note
note.destroy
```

---

## Controllers & Routes

### Students Controller

The Students Controller handles all CRUD operations for students.

#### Routes

| Method | Path | Action | Description |
|--------|------|--------|-------------|
| GET | `/students` | index | List all students |
| GET | `/students/new` | new | Show form to create student |
| POST | `/students` | create | Create a new student |
| GET | `/students/:id` | show | Show a specific student |
| GET | `/students/:id/edit` | edit | Show form to edit student |
| PATCH/PUT | `/students/:id` | update | Update a student |
| DELETE | `/students/:id` | destroy | Delete a student |

#### Actions

##### `index`

Lists all students ordered by percentage (highest to lowest).

**Response**: Renders `students/index.html.erb` with `@students` instance variable

**Example Request**:
```
GET /students
```

---

##### `show`

Displays a specific student's details.

**Parameters**:
- `id` (required) - Student ID

**Response**: Renders `students/show.html.erb` with `@student` instance variable

**Example Request**:
```
GET /students/1
```

---

##### `new`

Shows the form to create a new student.

**Response**: Renders `students/new.html.erb` with a new `@student` instance

**Example Request**:
```
GET /students/new
```

---

##### `create`

Creates a new student with automatically calculated scores.

**Parameters**:
```ruby
{
  student: {
    name: "string",      # required
    reading: integer,    # required, 0-10
    writing: integer,    # required, 0-10
    listening: integer,  # required, 0-10
    speaking: integer    # required, 0-10
  }
}
```

**Success Response**:
- Redirects to student show page with notice: "Student successfully created"

**Error Response**:
- Renders `students/new.html.erb` with validation errors

**Example Request**:
```
POST /students
Content-Type: application/x-www-form-urlencoded

student[name]=Jane+Smith&student[reading]=9&student[writing]=8&student[listening]=9&student[speaking]=7
```

---

##### `edit`

Shows the form to edit an existing student.

**Parameters**:
- `id` (required) - Student ID

**Response**: Renders `students/edit.html.erb` with `@student` instance variable

**Example Request**:
```
GET /students/1/edit
```

---

##### `update`

Updates an existing student with automatically recalculated scores.

**Parameters**:
- `id` (required) - Student ID
```ruby
{
  student: {
    name: "string",      # optional
    reading: integer,    # optional, 0-10
    writing: integer,    # optional, 0-10
    listening: integer,  # optional, 0-10
    speaking: integer    # optional, 0-10
  }
}
```

**Success Response**:
- Redirects to student show page with notice: "Student successfully updated"

**Error Response**:
- Renders `students/edit.html.erb` with validation errors

**Example Request**:
```
PATCH /students/1
Content-Type: application/x-www-form-urlencoded

student[reading]=10&student[writing]=9
```

---

##### `destroy`

Deletes a student and all associated notes.

**Parameters**:
- `id` (required) - Student ID

**Success Response**:
- Redirects to students index with notice: "Student successfully deleted"

**Example Request**:
```
DELETE /students/1
```

---

#### Private Methods

##### `set_student`

Sets `@student` instance variable by finding the student from params[:id].

**Used by**: show, edit, update, destroy actions

---

##### `student_params`

Strong parameters method for student creation/update.

**Permitted Parameters**: name, reading, writing, listening, speaking

---

##### `calculate_scores(student)`

Calculates and sets total_score and percentage for a student.

**Logic**:
```ruby
student.total_score = student.reading + student.writing + student.listening + student.speaking
student.percentage = (student.total_score / 40.0) * 100
```

**Used by**: create, update actions (called before saving)

---

### Notes Controller

The Notes Controller handles all CRUD operations for notes within the context of a student.

#### Routes

| Method | Path | Action | Description |
|--------|------|--------|-------------|
| GET | `/students/:student_id/notes` | index | List all notes for a student |
| GET | `/students/:student_id/notes/new` | new | Show form to create note |
| POST | `/students/:student_id/notes` | create | Create a new note |
| GET | `/students/:student_id/notes/:id` | show | Show a specific note |
| GET | `/students/:student_id/notes/:id/edit` | edit | Show form to edit note |
| PATCH/PUT | `/students/:student_id/notes/:id` | update | Update a note |
| DELETE | `/students/:student_id/notes/:id` | destroy | Delete a note |

#### Actions

##### `index`

Lists all notes for a specific student, ordered by creation date (newest first).

**Parameters**:
- `student_id` (required) - Student ID

**Response**: Renders `notes/index.html.erb` with `@notes` and `@student` instance variables

**Example Request**:
```
GET /students/1/notes
```

---

##### `show`

Displays a specific note.

**Parameters**:
- `student_id` (required) - Student ID
- `id` (required) - Note ID

**Response**: Renders `notes/show.html.erb` with `@note` and `@student` instance variables

**Example Request**:
```
GET /students/1/notes/5
```

---

##### `new`

Shows the form to create a new note for a student.

**Parameters**:
- `student_id` (required) - Student ID

**Response**: Renders `notes/new.html.erb` with a new `@note` instance and `@student`

**Example Request**:
```
GET /students/1/notes/new
```

---

##### `create`

Creates a new note for a student.

**Parameters**:
- `student_id` (required) - Student ID
```ruby
{
  note: {
    content: "string"  # required, 1-1000 characters
  }
}
```

**Success Response**:
- Redirects to student show page with notice: "Note was successfully created."

**Error Response**:
- Renders `notes/new.html.erb` with validation errors

**Example Request**:
```
POST /students/1/notes
Content-Type: application/x-www-form-urlencoded

note[content]=Great+improvement+in+pronunciation
```

---

##### `edit`

Shows the form to edit an existing note.

**Parameters**:
- `student_id` (required) - Student ID
- `id` (required) - Note ID

**Response**: Renders `notes/edit.html.erb` with `@note` and `@student` instance variables

**Example Request**:
```
GET /students/1/notes/5/edit
```

---

##### `update`

Updates an existing note.

**Parameters**:
- `student_id` (required) - Student ID
- `id` (required) - Note ID
```ruby
{
  note: {
    content: "string"  # required, 1-1000 characters
  }
}
```

**Success Response**:
- Redirects to student show page with notice: "Note was successfully updated."

**Error Response**:
- Renders `notes/edit.html.erb` with validation errors

**Example Request**:
```
PATCH /students/1/notes/5
Content-Type: application/x-www-form-urlencoded

note[content]=Exceptional+progress+in+all+areas
```

---

##### `destroy`

Deletes a note.

**Parameters**:
- `student_id` (required) - Student ID
- `id` (required) - Note ID

**Success Response**:
- Redirects to student show page with notice: "Note was successfully deleted."

**Example Request**:
```
DELETE /students/1/notes/5
```

---

#### Private Methods

##### `set_student`

Sets `@student` instance variable by finding the student from params[:student_id].

**Used by**: All actions (via before_action)

---

##### `set_note`

Sets `@note` instance variable by finding the note from params[:id] within the student's notes.

**Used by**: show, edit, update, destroy actions (via before_action)

---

##### `note_params`

Strong parameters method for note creation/update.

**Permitted Parameters**: content

---

## JavaScript Components

### Stimulus Controllers

The application uses Stimulus.js for JavaScript interactions.

#### Application Controller

Base configuration for Stimulus application.

**Location**: `app/javascript/controllers/application.js`

**Configuration**:
- Debug mode: disabled in production
- Global access via `window.Stimulus`

---

#### Hello Controller

Example Stimulus controller (can be removed or customized).

**Location**: `app/javascript/controllers/hello_controller.js`

**Usage**:
```html
<div data-controller="hello"></div>
<!-- Will display "Hello World!" when connected -->
```

**Methods**:
- `connect()` - Sets element text content to "Hello World!"

---

## API Examples

### Complete Workflow Examples

#### Example 1: Creating a Student with Notes

```ruby
# Step 1: Create a student
student = Student.create(
  name: "Alice Johnson",
  reading: 9,
  writing: 8,
  listening: 9,
  speaking: 10
)
# => total_score: 36, percentage: 90.0

# Step 2: Add notes to the student
student.notes.create(content: "Excellent pronunciation and fluency")
student.notes.create(content: "Shows great understanding of complex texts")

# Step 3: Retrieve student with notes
student = Student.includes(:notes).find(student.id)
puts "Student: #{student.name}"
puts "Score: #{student.percentage}%"
puts "Notes:"
student.notes.each { |note| puts "- #{note.content}" }
```

---

#### Example 2: Updating Student Scores

```ruby
# Find student
student = Student.find(1)

# Update scores
student.update(
  reading: 10,
  speaking: 9
)
# Scores are automatically recalculated

puts "New total: #{student.total_score}"
puts "New percentage: #{student.percentage}%"
```

---

#### Example 3: Bulk Operations

```ruby
# Get top 5 students
top_students = Student.order(percentage: :desc).limit(5)

# Get all students with scores above 80%
high_performers = Student.where('percentage > ?', 80)

# Get students with their notes count
students_with_notes = Student.left_joins(:notes)
                             .select('students.*, COUNT(notes.id) as notes_count')
                             .group('students.id')
                             .order('notes_count DESC')
```

---

#### Example 4: Working with Notes

```ruby
# Find a student
student = Student.find(1)

# Get recent notes
recent_notes = student.notes.order(created_at: :desc).limit(5)

# Search notes by content
notes_with_keyword = student.notes.where('content ILIKE ?', '%improvement%')

# Update multiple notes
student.notes.where('created_at < ?', 1.month.ago)
             .update_all(content: "Archived: " + content)
```

---

## Error Handling

### Validation Errors

#### Student Validation Errors

**Empty name**:
```ruby
student = Student.new(reading: 5, writing: 5, listening: 5, speaking: 5)
student.valid?  # => false
student.errors.full_messages  # => ["Name can't be blank"]
```

**Invalid score range**:
```ruby
student = Student.new(name: "Test", reading: 11, writing: 5, listening: 5, speaking: 5)
student.valid?  # => false
student.errors.full_messages  # => ["Reading must be in 0..10"]
```

**Missing scores**:
```ruby
student = Student.new(name: "Test", reading: 5)
student.valid?  # => false
student.errors.full_messages  
# => ["Writing can't be blank", "Writing must be in 0..10", "Listening can't be blank", ...]
```

---

#### Note Validation Errors

**Empty content**:
```ruby
note = Note.new(student: student)
note.valid?  # => false
note.errors.full_messages  # => ["Content can't be blank"]
```

**Content too long**:
```ruby
note = Note.new(student: student, content: "a" * 1001)
note.valid?  # => false
note.errors.full_messages  # => ["Content is too long (maximum is 1000 characters)"]
```

---

### HTTP Error Responses

#### 404 Not Found

Occurs when trying to access a non-existent student or note.

```ruby
# Student not found
Student.find(999)  # Raises ActiveRecord::RecordNotFound

# Note not found for student
student.notes.find(999)  # Raises ActiveRecord::RecordNotFound
```

---

#### 422 Unprocessable Entity

Returned when validation fails during create or update operations.

**Example**: Trying to create a student with invalid data via form submission will render the form again with error messages.

---

### Controller Error Handling

Controllers use Rails' default error handling:

- **RecordNotFound**: Renders 404 error page
- **Validation failures**: Re-renders form with error messages
- **Successful operations**: Redirects with flash notice

---

## Additional Resources

### Database Schema

```ruby
# Students table
create_table "students" do |t|
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

# Notes table
create_table "notes" do |t|
  t.text "content"
  t.bigint "student_id", null: false
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["student_id"], name: "index_notes_on_student_id"
end

add_foreign_key "notes", "students"
```

---

### Configuration

#### Database

- **Development/Test**: PostgreSQL
- **Production**: PostgreSQL with SSL

#### Caching

- **Solid Cache**: Database-backed cache store

#### Background Jobs

- **Solid Queue**: Database-backed Active Job adapter

#### Cable

- **Solid Cable**: Database-backed Action Cable adapter

---

### Running the Application

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Run the server
rails server

# Run tests
rails test

# Run system tests
rails test:system
```

---

### Health Check

The application includes a health check endpoint:

```
GET /up
```

This endpoint can be used to verify the application is running properly.

---

## Version Information

- **Rails Version**: 8.0.3
- **Ruby Version**: (Check Gemfile.lock for exact version)
- **Database**: PostgreSQL 1.1+
- **Server**: Puma 5.0+

---

## Support and Contact

For issues or questions about this API, please refer to the project README or contact the development team.