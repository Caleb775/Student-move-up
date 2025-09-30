# Student Management System - API Documentation

## Overview

This is a Ruby on Rails application for managing students and their notes. The system allows you to track student performance across four language skills (reading, writing, listening, speaking) and maintain notes for each student.

## Table of Contents

1. [Models](#models)
   - [Student Model](#student-model)
   - [Note Model](#note-model)
2. [Controllers](#controllers)
   - [StudentsController](#studentscontroller)
   - [NotesController](#notescontroller)
3. [Routes](#routes)
4. [JavaScript Components](#javascript-components)
5. [Database Schema](#database-schema)
6. [Usage Examples](#usage-examples)

---

## Models

### Student Model

**Class:** `Student`  
**File:** `app/models/student.rb`

The Student model represents a student in the system with language proficiency scores.

#### Attributes

| Attribute | Type | Description | Validation |
|-----------|------|-------------|------------|
| `name` | String | Student's full name | Required |
| `reading` | Integer | Reading proficiency score | Required, 0-10 |
| `writing` | Integer | Writing proficiency score | Required, 0-10 |
| `listening` | Integer | Listening proficiency score | Required, 0-10 |
| `speaking` | Integer | Speaking proficiency score | Required, 0-10 |
| `total_score` | Integer | Sum of all four scores | Auto-calculated |
| `percentage` | Float | Percentage score (total/40 * 100) | Auto-calculated |
| `created_at` | DateTime | Record creation timestamp | Auto-generated |
| `updated_at` | DateTime | Record last update timestamp | Auto-generated |

#### Associations

- `has_many :notes, dependent: :destroy` - A student can have many notes, and deleting a student will delete all associated notes

#### Validations

```ruby
validates :name, presence: true
validates :reading, :writing, :listening, :speaking,
          presence: true,
          numericality: { in: 0..10 }
```

#### Usage Examples

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

# Access student's notes
student.notes

# Calculate scores manually (usually done automatically in controller)
student.total_score = student.reading + student.writing + student.listening + student.speaking
student.percentage = (student.total_score / 40.0) * 100
```

---

### Note Model

**Class:** `Note`  
**File:** `app/models/note.rb`

The Note model represents a note associated with a student.

#### Attributes

| Attribute | Type | Description | Validation |
|-----------|------|-------------|------------|
| `content` | Text | Note content | Required, 1-1000 characters |
| `student_id` | Integer | Foreign key to student | Required |
| `created_at` | DateTime | Record creation timestamp | Auto-generated |
| `updated_at` | DateTime | Record last update timestamp | Auto-generated |

#### Associations

- `belongs_to :student` - Each note belongs to one student

#### Validations

```ruby
validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
```

#### Usage Examples

```ruby
# Create a new note for a student
student = Student.find(1)
note = student.notes.build(content: "Excellent progress in speaking skills")
note.save

# Access the student from a note
note.student
```

---

## Controllers

### StudentsController

**Class:** `StudentsController`  
**File:** `app/controllers/students_controller.rb`  
**Parent:** `ApplicationController`

Handles all HTTP requests related to student management.

#### Actions

##### `index`
- **Method:** GET
- **Path:** `/students`
- **Description:** Lists all students ordered by percentage (highest scores first)
- **Instance Variables:** `@students`

```ruby
def index
  @students = Student.order(percentage: :desc)
end
```

##### `show`
- **Method:** GET
- **Path:** `/students/:id`
- **Description:** Shows details for a specific student
- **Before Action:** `set_student`
- **Instance Variables:** `@student`

##### `new`
- **Method:** GET
- **Path:** `/students/new`
- **Description:** Shows form to create a new student
- **Instance Variables:** `@student`

##### `create`
- **Method:** POST
- **Path:** `/students`
- **Description:** Creates a new student
- **Parameters:** Student attributes (name, reading, writing, listening, speaking)
- **Redirects:** To student show page on success, renders new form on failure

```ruby
def create
  @student = Student.new(student_params)
  calculate_scores(@student)
  if @student.save
    redirect_to @student, notice: "Student successfully created"
  else
    render :new
  end
end
```

##### `edit`
- **Method:** GET
- **Path:** `/students/:id/edit`
- **Description:** Shows form to edit an existing student
- **Before Action:** `set_student`
- **Instance Variables:** `@student`

##### `update`
- **Method:** PATCH/PUT
- **Path:** `/students/:id`
- **Description:** Updates an existing student
- **Before Action:** `set_student`
- **Parameters:** Student attributes
- **Redirects:** To student show page on success, renders edit form on failure

##### `destroy`
- **Method:** DELETE
- **Path:** `/students/:id`
- **Description:** Deletes a student and all associated notes
- **Before Action:** `set_student`
- **Redirects:** To students index page

#### Private Methods

##### `set_student`
```ruby
def set_student
  @student = Student.find(params[:id])
end
```

##### `student_params`
```ruby
def student_params
  params.require(:student).permit(:name, :reading, :writing, :listening, :speaking)
end
```

##### `calculate_scores(student)`
```ruby
def calculate_scores(student)
  student.total_score = student.reading + student.writing + student.listening + student.speaking
  student.percentage = (student.total_score / 40.0) * 100
end
```

---

### NotesController

**Class:** `NotesController`  
**File:** `app/controllers/notes_controller.rb`  
**Parent:** `ApplicationController`

Handles all HTTP requests related to note management for students.

#### Actions

##### `index`
- **Method:** GET
- **Path:** `/students/:student_id/notes`
- **Description:** Lists all notes for a specific student (newest first)
- **Before Actions:** `set_student`
- **Instance Variables:** `@notes`, `@student`

##### `show`
- **Method:** GET
- **Path:** `/students/:student_id/notes/:id`
- **Description:** Shows a specific note
- **Before Actions:** `set_student`, `set_note`
- **Instance Variables:** `@note`, `@student`

##### `new`
- **Method:** GET
- **Path:** `/students/:student_id/notes/new`
- **Description:** Shows form to create a new note for a student
- **Before Actions:** `set_student`
- **Instance Variables:** `@note`, `@student`

##### `create`
- **Method:** POST
- **Path:** `/students/:student_id/notes`
- **Description:** Creates a new note for a student
- **Before Actions:** `set_student`
- **Parameters:** Note content
- **Redirects:** To student show page on success, renders new form on failure

##### `edit`
- **Method:** GET
- **Path:** `/students/:student_id/notes/:id/edit`
- **Description:** Shows form to edit an existing note
- **Before Actions:** `set_student`, `set_note`
- **Instance Variables:** `@note`, `@student`

##### `update`
- **Method:** PATCH/PUT
- **Path:** `/students/:student_id/notes/:id`
- **Description:** Updates an existing note
- **Before Actions:** `set_student`, `set_note`
- **Parameters:** Note content
- **Redirects:** To student show page on success, renders edit form on failure

##### `destroy`
- **Method:** DELETE
- **Path:** `/students/:student_id/notes/:id`
- **Description:** Deletes a note
- **Before Actions:** `set_student`, `set_note`
- **Redirects:** To student show page

#### Private Methods

##### `set_student`
```ruby
def set_student
  @student = Student.find(params[:student_id])
end
```

##### `set_note`
```ruby
def set_note
  @note = @student.notes.find(params[:id])
end
```

##### `note_params`
```ruby
def note_params
  params.require(:note).permit(:content)
end
```

---

## Routes

**File:** `config/routes.rb`

The application uses Rails RESTful routing with nested resources.

```ruby
Rails.application.routes.draw do
  resources :students do
    resources :notes
  end

  root "students#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
```

### Generated Routes

#### Student Routes

| HTTP Method | Path | Controller Action | Description |
|-------------|------|-------------------|-------------|
| GET | `/students` | `students#index` | List all students |
| GET | `/students/new` | `students#new` | New student form |
| POST | `/students` | `students#create` | Create student |
| GET | `/students/:id` | `students#show` | Show student |
| GET | `/students/:id/edit` | `students#edit` | Edit student form |
| PATCH/PUT | `/students/:id` | `students#update` | Update student |
| DELETE | `/students/:id` | `students#destroy` | Delete student |

#### Note Routes (Nested)

| HTTP Method | Path | Controller Action | Description |
|-------------|------|-------------------|-------------|
| GET | `/students/:student_id/notes` | `notes#index` | List student's notes |
| GET | `/students/:student_id/notes/new` | `notes#new` | New note form |
| POST | `/students/:student_id/notes` | `notes#create` | Create note |
| GET | `/students/:student_id/notes/:id` | `notes#show` | Show note |
| GET | `/students/:student_id/notes/:id/edit` | `notes#edit` | Edit note form |
| PATCH/PUT | `/students/:student_id/notes/:id` | `notes#update` | Update note |
| DELETE | `/students/:student_id/notes/:id` | `notes#destroy` | Delete note |

#### Other Routes

| HTTP Method | Path | Controller Action | Description |
|-------------|------|-------------------|-------------|
| GET | `/` | `students#index` | Root path (redirects to students) |
| GET | `/up` | `rails/health#show` | Health check endpoint |

---

## JavaScript Components

### Hello Controller

**Class:** `HelloController`  
**File:** `app/javascript/controllers/hello_controller.js`

A simple Stimulus controller that displays "Hello World!" when connected to a DOM element.

#### Methods

##### `connect()`
- **Description:** Called when the controller is connected to a DOM element
- **Behavior:** Sets the element's text content to "Hello World!"

```javascript
connect() {
  this.element.textContent = "Hello World!"
}
```

#### Usage

To use this controller in your HTML:

```html
<div data-controller="hello">
  <!-- Content will be replaced with "Hello World!" -->
</div>
```

### Application JavaScript

**File:** `app/javascript/application.js`

The main JavaScript entry point that imports and configures Turbo and Stimulus.

```javascript
import "@hotwired/turbo-rails"
import "controllers"
```

---

## Database Schema

**File:** `db/schema.rb`

### Tables

#### `students` table

```sql
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
```

#### `notes` table

```sql
create_table "notes", force: :cascade do |t|
  t.text "content"
  t.bigint "student_id", null: false
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["student_id"], name: "index_notes_on_student_id"
end
```

#### Foreign Key

```sql
add_foreign_key "notes", "students"
```

---

## Usage Examples

### Creating a Student via Rails Console

```ruby
# Start Rails console
rails console

# Create a new student
student = Student.new(
  name: "Alice Johnson",
  reading: 9,
  writing: 8,
  listening: 7,
  speaking: 9
)

# Calculate scores
student.total_score = student.reading + student.writing + student.listening + student.speaking
student.percentage = (student.total_score / 40.0) * 100

# Save the student
student.save

# Create a note for the student
note = student.notes.create(content: "Alice shows excellent progress in reading comprehension and vocabulary.")
```

### HTTP API Examples

#### Create a Student

```bash
curl -X POST http://localhost:3000/students \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "student[name]=Bob Smith&student[reading]=8&student[writing]=7&student[listening]=9&student[speaking]=8"
```

#### Get All Students

```bash
curl http://localhost:3000/students
```

#### Create a Note for a Student

```bash
curl -X POST http://localhost:3000/students/1/notes \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "note[content]=Bob needs more practice with pronunciation."
```

#### Update a Student

```bash
curl -X PATCH http://localhost:3000/students/1 \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "student[name]=Bob Smith&student[reading]=9&student[writing]=8&student[listening]=9&student[speaking]=9"
```

#### Delete a Student

```bash
curl -X DELETE http://localhost:3000/students/1
```

### View Examples

#### Student Index View

```erb
<h1>Students</h1>

<% @students.each do |student| %>
  <div class="student-card">
    <h3><%= student.name %></h3>
    <p>Total Score: <%= student.total_score %>/40</p>
    <p>Percentage: <%= number_to_percentage(student.percentage, precision: 1) %></p>
    <p>Skills: Reading: <%= student.reading %>, Writing: <%= student.writing %>, Listening: <%= student.listening %>, Speaking: <%= student.speaking %></p>
    <%= link_to "View", student_path(student) %>
    <%= link_to "Edit", edit_student_path(student) %>
    <%= link_to "Delete", student_path(student), method: :delete, confirm: "Are you sure?" %>
  </div>
<% end %>

<%= link_to "Add New Student", new_student_path %>
```

#### Note Form

```erb
<%= form_with model: [@student, @note], local: true do |form| %>
  <% if @note.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@note.errors.count, "error") %> prohibited this note from being saved:</h2>
      <ul>
        <% @note.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= form.label :content %>
    <%= form.text_area :content, rows: 5 %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

### Testing Examples

#### Model Tests

```ruby
# test/models/student_test.rb
require "test_helper"

class StudentTest < ActiveSupport::TestCase
  test "should create valid student" do
    student = Student.new(
      name: "Test Student",
      reading: 8,
      writing: 7,
      listening: 9,
      speaking: 8
    )
    assert student.valid?
  end

  test "should require name" do
    student = Student.new(reading: 8, writing: 7, listening: 9, speaking: 8)
    assert_not student.valid?
    assert_includes student.errors[:name], "can't be blank"
  end

  test "should validate score ranges" do
    student = Student.new(name: "Test", reading: 11, writing: 7, listening: 9, speaking: 8)
    assert_not student.valid?
    assert_includes student.errors[:reading], "must be in 0..10"
  end
end
```

#### Controller Tests

```ruby
# test/controllers/students_controller_test.rb
require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get students_url
    assert_response :success
  end

  test "should create student" do
    assert_difference('Student.count') do
      post students_url, params: {
        student: {
          name: "Test Student",
          reading: 8,
          writing: 7,
          listening: 9,
          speaking: 8
        }
      }
    end

    assert_redirected_to student_url(Student.last)
  end
end
```

---

## Error Handling

### Model Validation Errors

The application includes comprehensive validation that will prevent invalid data:

- **Student name** must be present
- **All skill scores** must be present and between 0-10
- **Note content** must be present and between 1-1000 characters

### Controller Error Handling

- Failed validations redirect back to the form with error messages
- Missing records (404) are handled by Rails default behavior
- All actions include appropriate flash messages for user feedback

---

## Security Considerations

- All parameters are properly whitelisted using `strong_parameters`
- CSRF protection is enabled by default in Rails
- SQL injection is prevented through ActiveRecord's parameterized queries
- XSS protection is provided by Rails' default HTML escaping

---

## Performance Notes

- Students are ordered by percentage in the index action for quick access to top performers
- Notes are ordered by creation date (newest first) for recent updates
- Database indexes are in place on foreign keys for efficient joins
- The application uses Rails' built-in caching and optimization features

---

*This documentation covers all public APIs, functions, and components in the Student Management System. For additional information or questions, please refer to the Rails guides or contact the development team.*