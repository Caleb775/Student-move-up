# Controllers Documentation

## Overview

This document provides comprehensive documentation for all controllers in the Student Management System, including their actions, parameters, responses, and internal methods.

## ApplicationController

**File:** `app/controllers/application_controller.rb`

### Description

Base controller class that all other controllers inherit from. Provides common functionality and configuration for the entire application.

### Configuration

```ruby
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
```

**Browser Support:**
- Restricts access to modern browsers only
- Ensures compatibility with modern web features like webp images, web push, badges, import maps, CSS nesting, and CSS :has selector

### Inherited Methods

All controllers inherit standard Rails controller functionality:
- CSRF protection
- Parameter filtering
- Session management
- Cookie handling
- Request/response processing

---

## StudentsController

**File:** `app/controllers/students_controller.rb`

### Description

Handles all CRUD operations for students, including score calculations and validations.

### Before Actions

```ruby
before_action :set_student, only: [:show, :edit, :update, :destroy]
```

**Applied to:** `show`, `edit`, `update`, `destroy` actions
**Purpose:** Finds and sets the `@student` instance variable for actions that operate on a specific student

### Actions

#### `index` - GET /students

**Purpose:** Display all students ordered by percentage score (highest first)

**Parameters:** None

**Instance Variables:**
- `@students` - Collection of all students ordered by percentage (descending)

**Query:**
```ruby
@students = Student.order(percentage: :desc)
```

**Response:** Renders `students/index` view

**Example Usage:**
```ruby
# Controller action
def index
  @students = Student.order(percentage: :desc) # top scores first
end
```

---

#### `show` - GET /students/:id

**Purpose:** Display a specific student's details

**Parameters:**
- `id` (required) - Student ID from URL params

**Instance Variables:**
- `@student` - The specific student (set by `set_student` before_action)

**Response:** Renders `students/show` view

**Error Handling:** Returns 404 if student not found

---

#### `new` - GET /students/new

**Purpose:** Display form for creating a new student

**Parameters:** None

**Instance Variables:**
- `@student` - New Student instance for form binding

**Implementation:**
```ruby
def new
  @student = Student.new
end
```

**Response:** Renders `students/new` view with form

---

#### `create` - POST /students

**Purpose:** Create a new student with score calculations

**Parameters:**
- `student` (required) - Hash containing student attributes
  - `name` (required) - Student's name
  - `reading` (required) - Reading score (0-10)
  - `writing` (required) - Writing score (0-10)
  - `listening` (required) - Listening score (0-10)
  - `speaking` (required) - Speaking score (0-10)

**Process Flow:**
1. Create new Student instance with permitted parameters
2. Calculate total score and percentage using `calculate_scores` method
3. Attempt to save the student
4. Redirect on success or re-render form on failure

**Implementation:**
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

**Success Response:** Redirect to student show page with success notice
**Error Response:** Re-render new form with validation errors

---

#### `edit` - GET /students/:id/edit

**Purpose:** Display form for editing an existing student

**Parameters:**
- `id` (required) - Student ID from URL params

**Instance Variables:**
- `@student` - The student to edit (set by `set_student` before_action)

**Response:** Renders `students/edit` view with populated form

---

#### `update` - PATCH/PUT /students/:id

**Purpose:** Update an existing student with recalculated scores

**Parameters:**
- `id` (required) - Student ID from URL params
- `student` (required) - Hash containing updated student attributes

**Process Flow:**
1. Assign new attributes to existing student (without saving)
2. Recalculate scores using `calculate_scores` method
3. Attempt to save the updated student
4. Redirect on success or re-render form on failure

**Implementation:**
```ruby
def update
  @student.assign_attributes(student_params)
  calculate_scores(@student)
  if @student.save
    redirect_to @student, notice: "Student successfully updated"
  else
    render :edit
  end
end
```

**Success Response:** Redirect to student show page with success notice
**Error Response:** Re-render edit form with validation errors

---

#### `destroy` - DELETE /students/:id

**Purpose:** Delete a student and all associated notes

**Parameters:**
- `id` (required) - Student ID from URL params

**Instance Variables:**
- `@student` - The student to delete (set by `set_student` before_action)

**Process Flow:**
1. Find student (via before_action)
2. Delete student (cascades to delete associated notes)
3. Redirect to students index with success notice

**Implementation:**
```ruby
def destroy
  @student.destroy
  redirect_to students_path, notice: "Student successfully deleted"
end
```

**Response:** Redirect to students index page with success notice

### Private Methods

#### `set_student`

**Purpose:** Find and set the student for actions that operate on a specific student

**Implementation:**
```ruby
private

def set_student
  @student = Student.find(params[:id])
end
```

**Error Handling:** Raises `ActiveRecord::RecordNotFound` if student doesn't exist (handled by Rails as 404)

---

#### `student_params`

**Purpose:** Strong parameters filtering for student attributes

**Implementation:**
```ruby
private

def student_params
  params.require(:student).permit(:name, :reading, :writing, :listening, :speaking)
end
```

**Permitted Parameters:**
- `name` - Student's name
- `reading` - Reading score
- `writing` - Writing score
- `listening` - Listening score
- `speaking` - Speaking score

**Security:** Prevents mass assignment vulnerabilities by only allowing specified parameters

---

#### `calculate_scores(student)`

**Purpose:** Calculate total score and percentage for a student

**Parameters:**
- `student` - Student instance to calculate scores for

**Implementation:**
```ruby
private

def calculate_scores(student)
  student.total_score = student.reading + student.writing + student.listening + student.speaking
  student.percentage = (student.total_score / 40.0) * 100  # 4 categories, max 10 each
end
```

**Calculations:**
- `total_score`: Sum of all four skill scores (max 40)
- `percentage`: Total score as percentage of maximum possible (40 points = 100%)

**Note:** This method modifies the student object but doesn't save it

---

## NotesController

**File:** `app/controllers/notes_controller.rb`

### Description

Handles all CRUD operations for notes associated with students. All note operations are scoped to a specific student.

### Before Actions

```ruby
before_action :set_student
before_action :set_note, only: [:show, :edit, :update, :destroy]
```

**Applied to all actions:** `set_student` - Ensures all operations are scoped to a specific student
**Applied to specific actions:** `set_note` - Finds the specific note for actions that operate on individual notes

### Actions

#### `index` - GET /students/:student_id/notes

**Purpose:** Display all notes for a specific student

**Parameters:**
- `student_id` (required) - Student ID from URL params

**Instance Variables:**
- `@student` - The student whose notes are being displayed
- `@notes` - Collection of notes for the student, ordered by creation date (newest first)

**Implementation:**
```ruby
def index
  @notes = @student.notes.order(created_at: :desc)
end
```

**Response:** Renders `notes/index` view

---

#### `show` - GET /students/:student_id/notes/:id

**Purpose:** Display a specific note

**Parameters:**
- `student_id` (required) - Student ID from URL params
- `id` (required) - Note ID from URL params

**Instance Variables:**
- `@student` - The student who owns the note
- `@note` - The specific note (set by `set_note` before_action)

**Response:** Renders `notes/show` view

---

#### `new` - GET /students/:student_id/notes/new

**Purpose:** Display form for creating a new note for a student

**Parameters:**
- `student_id` (required) - Student ID from URL params

**Instance Variables:**
- `@student` - The student for whom the note is being created
- `@note` - New Note instance associated with the student

**Implementation:**
```ruby
def new
  @note = @student.notes.build
end
```

**Response:** Renders `notes/new` view with form

---

#### `create` - POST /students/:student_id/notes

**Purpose:** Create a new note for a student

**Parameters:**
- `student_id` (required) - Student ID from URL params
- `note` (required) - Hash containing note attributes
  - `content` (required) - Note content (1-1000 characters)

**Process Flow:**
1. Build new note associated with the student
2. Attempt to save the note
3. Redirect to student page on success or re-render form on failure

**Implementation:**
```ruby
def create
  @note = @student.notes.build(note_params)
  if @note.save
    redirect_to student_path(@student), notice: "Note was successfully created."
  else
    render :new
  end
end
```

**Success Response:** Redirect to student show page with success notice
**Error Response:** Re-render new form with validation errors

---

#### `edit` - GET /students/:student_id/notes/:id/edit

**Purpose:** Display form for editing an existing note

**Parameters:**
- `student_id` (required) - Student ID from URL params
- `id` (required) - Note ID from URL params

**Instance Variables:**
- `@student` - The student who owns the note
- `@note` - The note to edit (set by `set_note` before_action)

**Response:** Renders `notes/edit` view with populated form

---

#### `update` - PATCH/PUT /students/:student_id/notes/:id

**Purpose:** Update an existing note

**Parameters:**
- `student_id` (required) - Student ID from URL params
- `id` (required) - Note ID from URL params
- `note` (required) - Hash containing updated note attributes

**Process Flow:**
1. Find note (via before_action)
2. Attempt to update note with new attributes
3. Redirect to student page on success or re-render form on failure

**Implementation:**
```ruby
def update
  if @note.update(note_params)
    redirect_to student_path(@student), notice: "Note was successfully updated."
  else
    render :edit
  end
end
```

**Success Response:** Redirect to student show page with success notice
**Error Response:** Re-render edit form with validation errors

---

#### `destroy` - DELETE /students/:student_id/notes/:id

**Purpose:** Delete a specific note

**Parameters:**
- `student_id` (required) - Student ID from URL params
- `id` (required) - Note ID from URL params

**Process Flow:**
1. Find note (via before_action)
2. Delete the note
3. Redirect to student page with success notice

**Implementation:**
```ruby
def destroy
  @note.destroy
  redirect_to student_path(@student), notice: "Note was successfully deleted."
end
```

**Response:** Redirect to student show page with success notice

### Private Methods

#### `set_student`

**Purpose:** Find and set the student for all note operations

**Implementation:**
```ruby
private

def set_student
  @student = Student.find(params[:student_id])
end
```

**Error Handling:** Raises `ActiveRecord::RecordNotFound` if student doesn't exist

---

#### `set_note`

**Purpose:** Find and set the note within the scope of the current student

**Implementation:**
```ruby
private

def set_note
  @note = @student.notes.find(params[:id])
end
```

**Security:** Ensures notes can only be accessed within the context of their owning student
**Error Handling:** Raises `ActiveRecord::RecordNotFound` if note doesn't exist or doesn't belong to the student

---

#### `note_params`

**Purpose:** Strong parameters filtering for note attributes

**Implementation:**
```ruby
private

def note_params
  params.require(:note).permit(:content)
end
```

**Permitted Parameters:**
- `content` - Note content

**Security:** Prevents mass assignment vulnerabilities

---

## Common Patterns and Best Practices

### Error Handling

All controllers rely on Rails' built-in error handling:
- `ActiveRecord::RecordNotFound` exceptions are automatically converted to 404 responses
- Validation errors are handled by re-rendering forms with error messages
- CSRF protection is enabled by default

### Security Measures

1. **Strong Parameters:** All controllers use strong parameters to prevent mass assignment
2. **CSRF Protection:** Inherited from ApplicationController
3. **Scoped Access:** Notes controller ensures notes can only be accessed through their owning student
4. **Modern Browser Requirement:** ApplicationController restricts access to modern browsers

### Response Patterns

1. **Successful Creation/Update:** Redirect with success notice
2. **Validation Errors:** Re-render form with errors
3. **Successful Deletion:** Redirect with success notice
4. **Index Actions:** Render view with ordered collections

### Performance Considerations

1. **Efficient Queries:** Uses appropriate ordering for common use cases
2. **Scoped Queries:** Notes are always queried within student scope
3. **Before Actions:** Minimize database queries by reusing found records

### Flash Messages

Standard flash message patterns:
- `notice` for successful operations
- Automatic error display through form helpers for validation errors

### URL Structure

RESTful nested resource structure:
- Students: `/students`, `/students/:id`, etc.
- Notes: `/students/:student_id/notes`, `/students/:student_id/notes/:id`, etc.