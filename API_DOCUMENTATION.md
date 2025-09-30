# API Documentation

## Overview

This Ruby on Rails application provides a comprehensive Student Management System with scoring capabilities and note-taking functionality. The system manages students with language proficiency scores and allows adding notes to each student.

## Table of Contents

1. [Data Models](#data-models)
2. [REST API Endpoints](#rest-api-endpoints)
3. [JavaScript Components](#javascript-components)
4. [Usage Examples](#usage-examples)
5. [Data Validation](#data-validation)
6. [Database Schema](#database-schema)

---

## Data Models

### Student Model

The `Student` model represents a student with language proficiency scores in four categories.

**Attributes:**
- `name` (string, required): Student's full name
- `reading` (integer, required): Reading proficiency score (0-10)
- `writing` (integer, required): Writing proficiency score (0-10)
- `listening` (integer, required): Listening proficiency score (0-10)
- `speaking` (integer, required): Speaking proficiency score (0-10)
- `total_score` (integer): Automatically calculated sum of all scores
- `percentage` (float): Automatically calculated percentage (total_score/40 * 100)
- `created_at` (datetime): Record creation timestamp
- `updated_at` (datetime): Record last update timestamp

**Relationships:**
- `has_many :notes, dependent: :destroy` - A student can have multiple notes

**Validations:**
- `name`: Must be present
- `reading`, `writing`, `listening`, `speaking`: Must be present and numerical values between 0-10

**Example:**
```ruby
student = Student.create!(
  name: "John Doe",
  reading: 8,
  writing: 7,
  listening: 9,
  speaking: 6
)
# total_score will be automatically calculated as 30
# percentage will be automatically calculated as 75.0
```

### Note Model

The `Note` model represents notes associated with students.

**Attributes:**
- `content` (text, required): The note content (1-1000 characters)
- `student_id` (bigint, required): Foreign key to the associated student
- `created_at` (datetime): Record creation timestamp
- `updated_at` (datetime): Record last update timestamp

**Relationships:**
- `belongs_to :student` - Each note belongs to one student

**Validations:**
- `content`: Must be present with length between 1-1000 characters

**Example:**
```ruby
note = student.notes.create!(
  content: "Excellent progress in speaking. Needs more practice with writing."
)
```

---

## REST API Endpoints

### Students Controller

Base URL: `/students`

#### GET /students
Retrieves all students ordered by percentage (highest scores first).

**Response:**
- Status: 200 OK
- Content-Type: text/html
- Returns: Students index view with `@students` collection

**Example:**
```ruby
# In controller
@students = Student.order(percentage: :desc)
```

#### GET /students/:id
Retrieves a specific student by ID.

**Parameters:**
- `id` (integer, required): Student ID

**Response:**
- Status: 200 OK
- Content-Type: text/html
- Returns: Student show view with `@student` object

**Example:**
```ruby
# In controller
@student = Student.find(params[:id])
```

#### GET /students/new
Displays form to create a new student.

**Response:**
- Status: 200 OK
- Content-Type: text/html
- Returns: Student new view with `@student` object

**Example:**
```ruby
# In controller
@student = Student.new
```

#### POST /students
Creates a new student with calculated scores.

**Request Body:**
```ruby
{
  student: {
    name: "John Doe",
    reading: 8,
    writing: 7,
    listening: 9,
    speaking: 6
  }
}
```

**Response:**
- Success: 302 Redirect to student show page with notice
- Failure: 200 OK with new form and validation errors

**Score Calculation:**
- `total_score` = reading + writing + listening + speaking
- `percentage` = (total_score / 40.0) * 100

**Example:**
```ruby
# In controller
@student = Student.new(student_params)
calculate_scores(@student)
if @student.save
  redirect_to @student, notice: "Student successfully created"
else
  render :new
end
```

#### GET /students/:id/edit
Displays form to edit an existing student.

**Parameters:**
- `id` (integer, required): Student ID

**Response:**
- Status: 200 OK
- Content-Type: text/html
- Returns: Student edit view with `@student` object

**Example:**
```ruby
# In controller
@student = Student.find(params[:id])
```

#### PATCH/PUT /students/:id
Updates an existing student with recalculated scores.

**Parameters:**
- `id` (integer, required): Student ID

**Request Body:**
```ruby
{
  student: {
    name: "John Smith",
    reading: 9,
    writing: 8,
    listening: 9,
    speaking: 7
  }
}
```

**Response:**
- Success: 302 Redirect to student show page with notice
- Failure: 200 OK with edit form and validation errors

**Example:**
```ruby
# In controller
@student.assign_attributes(student_params)
calculate_scores(@student)
if @student.save
  redirect_to @student, notice: "Student successfully updated"
else
  render :edit
end
```

#### DELETE /students/:id
Deletes a student and all associated notes.

**Parameters:**
- `id` (integer, required): Student ID

**Response:**
- Status: 302 Redirect to students index with notice
- Note: All associated notes are automatically deleted due to `dependent: :destroy`

**Example:**
```ruby
# In controller
@student.destroy
redirect_to students_path, notice: "Student successfully deleted"
```

### Notes Controller

Base URL: `/students/:student_id/notes`

#### GET /students/:student_id/notes
Retrieves all notes for a specific student ordered by creation date (newest first).

**Parameters:**
- `student_id` (integer, required): Parent student ID

**Response:**
- Status: 200 OK
- Content-Type: text/html
- Returns: Notes index view with `@notes` collection

**Example:**
```ruby
# In controller
@notes = @student.notes.order(created_at: :desc)
```

#### GET /students/:student_id/notes/:id
Retrieves a specific note.

**Parameters:**
- `student_id` (integer, required): Parent student ID
- `id` (integer, required): Note ID

**Response:**
- Status: 200 OK
- Content-Type: text/html
- Returns: Note show view with `@note` object

**Example:**
```ruby
# In controller
@note = @student.notes.find(params[:id])
```

#### GET /students/:student_id/notes/new
Displays form to create a new note for a student.

**Parameters:**
- `student_id` (integer, required): Parent student ID

**Response:**
- Status: 200 OK
- Content-Type: text/html
- Returns: Note new view with `@note` object

**Example:**
```ruby
# In controller
@note = @student.notes.build
```

#### POST /students/:student_id/notes
Creates a new note for a student.

**Parameters:**
- `student_id` (integer, required): Parent student ID

**Request Body:**
```ruby
{
  note: {
    content: "Student shows great improvement in reading comprehension."
  }
}
```

**Response:**
- Success: 302 Redirect to student show page with notice
- Failure: 200 OK with new form and validation errors

**Example:**
```ruby
# In controller
@note = @student.notes.build(note_params)
if @note.save
  redirect_to student_path(@student), notice: "Note was successfully created."
else
  render :new
end
```

#### GET /students/:student_id/notes/:id/edit
Displays form to edit an existing note.

**Parameters:**
- `student_id` (integer, required): Parent student ID
- `id` (integer, required): Note ID

**Response:**
- Status: 200 OK
- Content-Type: text/html
- Returns: Note edit view with `@note` object

**Example:**
```ruby
# In controller
@note = @student.notes.find(params[:id])
```

#### PATCH/PUT /students/:student_id/notes/:id
Updates an existing note.

**Parameters:**
- `student_id` (integer, required): Parent student ID
- `id` (integer, required): Note ID

**Request Body:**
```ruby
{
  note: {
    content: "Updated note content with more details."
  }
}
```

**Response:**
- Success: 302 Redirect to student show page with notice
- Failure: 200 OK with edit form and validation errors

**Example:**
```ruby
# In controller
if @note.update(note_params)
  redirect_to student_path(@student), notice: "Note was successfully updated."
else
  render :edit
end
```

#### DELETE /students/:student_id/notes/:id
Deletes a note.

**Parameters:**
- `student_id` (integer, required): Parent student ID
- `id` (integer, required): Note ID

**Response:**
- Status: 302 Redirect to student show page with notice

**Example:**
```ruby
# In controller
@note.destroy
redirect_to student_path(@student), notice: "Note was successfully deleted."
```

---

## JavaScript Components

### Stimulus Application

The application uses Hotwired Stimulus for JavaScript functionality.

**Configuration:**
- Debug mode: Disabled in production
- Global access: Available as `window.Stimulus`

**File:** `app/javascript/controllers/application.js`

```javascript
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false
window.Stimulus = application

export { application }
```

### Hello Controller

A simple Stimulus controller that demonstrates basic functionality.

**File:** `app/javascript/controllers/hello_controller.js`

**Methods:**
- `connect()`: Automatically called when controller connects to DOM element

**Usage:**
```html
<div data-controller="hello">
  <!-- Content will be replaced with "Hello World!" -->
</div>
```

**Example:**
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
  }
}
```

### Controller Registration

All Stimulus controllers are automatically registered from the controllers directory.

**File:** `app/javascript/controllers/index.js`

```javascript
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
```

---

## Usage Examples

### Creating a Student with Scores

```ruby
# In Rails console or controller
student = Student.new(
  name: "Alice Johnson",
  reading: 9,
  writing: 8,
  listening: 9,
  speaking: 7
)

# Scores are automatically calculated when saved
student.save!
puts student.total_score  # => 33
puts student.percentage   # => 82.5
```

### Adding Notes to a Student

```ruby
# Create a note for an existing student
student = Student.find(1)
note = student.notes.create!(
  content: "Alice shows excellent progress in all areas. Focus on writing practice."
)

# Access notes through association
student.notes.each do |note|
  puts note.content
end
```

### Querying Students by Performance

```ruby
# Get top performers
top_students = Student.order(percentage: :desc).limit(5)

# Get students with specific score ranges
good_readers = Student.where(reading: 8..10)
average_students = Student.where(percentage: 60..80)
```

### HTTP API Usage

```bash
# Create a new student
curl -X POST http://localhost:3000/students \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "student[name]=John Doe&student[reading]=8&student[writing]=7&student[listening]=9&student[speaking]=6"

# Get all students
curl http://localhost:3000/students

# Create a note for a student
curl -X POST http://localhost:3000/students/1/notes \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "note[content]=Great progress in speaking skills!"
```

---

## Data Validation

### Student Validations

```ruby
# Name validation
student = Student.new(name: "")
student.valid?  # => false
student.errors[:name]  # => ["can't be blank"]

# Score validations
student = Student.new(name: "Test", reading: 15)
student.valid?  # => false
student.errors[:reading]  # => ["must be less than or equal to 10"]

student = Student.new(name: "Test", reading: -1)
student.valid?  # => false
student.errors[:reading]  # => ["must be greater than or equal to 0"]
```

### Note Validations

```ruby
# Content validation
note = Note.new(content: "")
note.valid?  # => false
note.errors[:content]  # => ["can't be blank"]

# Length validation
note = Note.new(content: "A" * 1001)
note.valid?  # => false
note.errors[:content]  # => ["is too long (maximum is 1000 characters)"]
```

---

## Database Schema

### Students Table

```sql
CREATE TABLE students (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  reading INTEGER NOT NULL CHECK (reading >= 0 AND reading <= 10),
  writing INTEGER NOT NULL CHECK (writing >= 0 AND writing <= 10),
  listening INTEGER NOT NULL CHECK (listening >= 0 AND listening <= 10),
  speaking INTEGER NOT NULL CHECK (speaking >= 0 AND speaking <= 10),
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
  content TEXT NOT NULL CHECK (length(content) >= 1 AND length(content) <= 1000),
  student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_notes_on_student_id ON notes(student_id);
```

### Relationships

- **One-to-Many**: Student → Notes
- **Foreign Key**: `notes.student_id` → `students.id`
- **Cascade Delete**: When a student is deleted, all associated notes are automatically deleted

---

## Error Handling

### Common HTTP Status Codes

- **200 OK**: Successful GET, POST/PUT/PATCH with validation errors
- **302 Found**: Successful POST/PUT/PATCH/DELETE (redirect)
- **404 Not Found**: Resource not found
- **422 Unprocessable Entity**: Validation errors (if using JSON API)
- **500 Internal Server Error**: Server error

### Validation Error Handling

```ruby
# In controller actions
if @student.save
  redirect_to @student, notice: "Student successfully created"
else
  render :new  # Shows form with validation errors
end
```

---

## Security Considerations

### Strong Parameters

All controllers use strong parameters to prevent mass assignment vulnerabilities:

```ruby
# StudentsController
def student_params
  params.require(:student).permit(:name, :reading, :writing, :listening, :speaking)
end

# NotesController
def note_params
  params.require(:note).permit(:content)
end
```

### SQL Injection Protection

The application uses ActiveRecord, which provides built-in SQL injection protection through parameterized queries.

---

## Performance Considerations

### Database Indexes

- Primary keys on both tables for fast lookups
- Foreign key index on `notes.student_id` for efficient joins

### Query Optimization

- Students are ordered by percentage in the index action
- Notes are ordered by creation date (newest first)
- Uses `dependent: :destroy` for efficient cascade deletion

---

This documentation covers all public APIs, functions, and components in the Student Management System. For additional help or questions, refer to the Rails guides or contact the development team.