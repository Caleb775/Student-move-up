# Usage Guide

Complete guide to using the Student Language Proficiency Tracker application.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Student Management](#student-management)
3. [Note Management](#note-management)
4. [Advanced Queries](#advanced-queries)
5. [Rails Console Examples](#rails-console-examples)
6. [Common Workflows](#common-workflows)
7. [Tips and Tricks](#tips-and-tricks)

---

## Quick Start

### Running the Application

```bash
# Start the server
rails server

# Visit in browser
http://localhost:3000
```

### Creating Your First Student

1. Navigate to `http://localhost:3000`
2. Click "New Student"
3. Fill in the form:
   - Name: "John Doe"
   - Reading: 8
   - Writing: 7
   - Listening: 9
   - Speaking: 8
4. Click "Create Student"

**Result**: Student is created with Total Score: 32/40 and Percentage: 80.0%

---

## Student Management

### Viewing All Students

**URL**: `http://localhost:3000/students` or `http://localhost:3000`

Students are displayed in a table, sorted by percentage (highest to lowest).

**What you see**:
- Student name
- Individual scores (Reading, Writing, Listening, Speaking)
- Total score
- Percentage
- Actions (View, Edit, Delete)

---

### Viewing a Single Student

**URL**: `http://localhost:3000/students/:id`

**What you see**:
- Complete student information
- All scores and percentages
- List of all notes for the student
- Options to add, edit, or delete notes

---

### Creating a Student

#### Via Web Interface

1. Go to `/students/new`
2. Fill in required fields:
   - **Name**: Student's full name (required)
   - **Reading**: Score 0-10 (required)
   - **Writing**: Score 0-10 (required)
   - **Listening**: Score 0-10 (required)
   - **Speaking**: Score 0-10 (required)
3. Submit the form

#### Via Rails Console

```ruby
rails console

# Create a student
student = Student.create(
  name: "Alice Johnson",
  reading: 9,
  writing: 8,
  listening: 9,
  speaking: 10
)

# Check if created successfully
if student.persisted?
  puts "Created: #{student.name} - #{student.percentage}%"
else
  puts "Errors: #{student.errors.full_messages}"
end
```

#### Via curl (API)

```bash
curl -X POST http://localhost:3000/students \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "student[name]=Jane+Smith" \
  -d "student[reading]=7" \
  -d "student[writing]=8" \
  -d "student[listening]=7" \
  -d "student[speaking]=9"
```

---

### Updating a Student

#### Via Web Interface

1. Go to student's page: `/students/:id`
2. Click "Edit Student"
3. Modify any fields
4. Click "Update Student"

**Note**: Scores are automatically recalculated when you update.

#### Via Rails Console

```ruby
student = Student.find(1)

# Update individual scores
student.update(reading: 10, speaking: 9)

# Or update all at once
student.update(
  name: "John Doe Jr.",
  reading: 9,
  writing: 8,
  listening: 10,
  speaking: 9
)

# Check new scores
puts "Total: #{student.total_score}"
puts "Percentage: #{student.percentage}%"
```

---

### Deleting a Student

#### Via Web Interface

1. Go to student's page: `/students/:id`
2. Click "Delete Student"
3. Confirm the deletion

**Warning**: This will also delete all notes associated with the student!

#### Via Rails Console

```ruby
student = Student.find(1)
student.destroy
# => All associated notes are automatically deleted (dependent: :destroy)
```

---

## Note Management

### Viewing Notes

#### All Notes for a Student

**URL**: `/students/:student_id/notes`

Or view them on the student's show page: `/students/:id`

#### Single Note

**URL**: `/students/:student_id/notes/:id`

---

### Creating a Note

#### Via Web Interface

1. Go to student's page: `/students/:id`
2. Click "Add Note" or "New Note"
3. Enter note content (1-1000 characters)
4. Click "Create Note"

#### Via Rails Console

```ruby
student = Student.find(1)

# Create a note
note = student.notes.create(
  content: "Excellent progress in speaking skills. Shows great confidence."
)

# Or
note = Note.create(
  student: student,
  content: "Needs more practice with reading comprehension."
)

# Verify
if note.persisted?
  puts "Note created: #{note.content[0..50]}..."
else
  puts "Errors: #{note.errors.full_messages}"
end
```

---

### Updating a Note

#### Via Web Interface

1. Go to student's page: `/students/:id`
2. Find the note
3. Click "Edit"
4. Modify content
5. Click "Update Note"

#### Via Rails Console

```ruby
note = Note.find(5)
note.update(content: "Outstanding improvement in all areas!")
```

---

### Deleting a Note

#### Via Web Interface

1. Go to student's page: `/students/:id`
2. Find the note
3. Click "Delete"
4. Confirm deletion

#### Via Rails Console

```ruby
note = Note.find(5)
note.destroy
```

---

## Advanced Queries

### Find Top Performers

```ruby
# Top 10 students
top_students = Student.order(percentage: :desc).limit(10)

top_students.each do |student|
  puts "#{student.name}: #{student.percentage}% (#{student.total_score}/40)"
end
```

---

### Find Students by Performance Level

```ruby
# High performers (80% or above)
high_performers = Student.where('percentage >= ?', 80)

# Medium performers (60-79%)
medium_performers = Student.where(percentage: 60..79)

# Need improvement (below 60%)
need_improvement = Student.where('percentage < ?', 60)

# Perfect scores in specific skill
perfect_readers = Student.where(reading: 10)
```

---

### Find Students by Score Range

```ruby
# Students with total score above 30
Student.where('total_score > ?', 30)

# Students with all scores above 7
Student.where('reading >= ? AND writing >= ? AND listening >= ? AND speaking >= ?', 7, 7, 7, 7)
```

---

### Search by Name

```ruby
# Case-insensitive search
Student.where('name ILIKE ?', '%john%')

# Students with names starting with 'A'
Student.where('name ILIKE ?', 'A%')
```

---

### Students with Most Notes

```ruby
# Get students with note count
students_with_notes = Student
  .left_joins(:notes)
  .select('students.*, COUNT(notes.id) as notes_count')
  .group('students.id')
  .order('notes_count DESC')

students_with_notes.each do |student|
  puts "#{student.name}: #{student.notes_count} notes"
end
```

---

### Find Notes by Content

```ruby
student = Student.find(1)

# Notes containing specific word
improvement_notes = student.notes.where('content ILIKE ?', '%improvement%')

# Recent notes (last 7 days)
recent_notes = student.notes.where('created_at >= ?', 7.days.ago)

# Old notes
old_notes = student.notes.where('created_at < ?', 30.days.ago)
```

---

## Rails Console Examples

### Bulk Operations

#### Create Multiple Students

```ruby
students_data = [
  { name: "Alice", reading: 9, writing: 8, listening: 9, speaking: 10 },
  { name: "Bob", reading: 7, writing: 7, listening: 8, speaking: 7 },
  { name: "Charlie", reading: 8, writing: 9, listening: 8, speaking: 9 }
]

students_data.each do |data|
  student = Student.new(data)
  student.total_score = student.reading + student.writing + student.listening + student.speaking
  student.percentage = (student.total_score / 40.0) * 100
  student.save
  puts "Created: #{student.name}"
end
```

---

#### Update All Students in a Range

```ruby
# Boost all scores by 1 for students below 60%
Student.where('percentage < ?', 60).find_each do |student|
  student.reading = [student.reading + 1, 10].min
  student.writing = [student.writing + 1, 10].min
  student.listening = [student.listening + 1, 10].min
  student.speaking = [student.speaking + 1, 10].min
  student.total_score = student.reading + student.writing + student.listening + student.speaking
  student.percentage = (student.total_score / 40.0) * 100
  student.save
  puts "Updated: #{student.name} - #{student.percentage}%"
end
```

---

### Calculations and Statistics

```ruby
# Average scores
avg_total = Student.average(:total_score)
avg_percentage = Student.average(:percentage)
puts "Average Total: #{avg_total.round(2)}"
puts "Average Percentage: #{avg_percentage.round(2)}%"

# Individual skill averages
puts "Average Reading: #{Student.average(:reading).round(2)}"
puts "Average Writing: #{Student.average(:writing).round(2)}"
puts "Average Listening: #{Student.average(:listening).round(2)}"
puts "Average Speaking: #{Student.average(:speaking).round(2)}"

# Min/Max scores
puts "Highest score: #{Student.maximum(:percentage)}%"
puts "Lowest score: #{Student.minimum(:percentage)}%"

# Total students
puts "Total students: #{Student.count}"
```

---

### Working with Associations

```ruby
# Load student with all notes (avoid N+1 queries)
student = Student.includes(:notes).find(1)

# Access notes without additional database queries
student.notes.each do |note|
  puts "- #{note.content}"
end

# Count notes without loading them
student.notes.count

# Check if student has notes
student.notes.any?
student.notes.empty?

# Get first/last note
student.notes.first
student.notes.last
```

---

## Common Workflows

### Workflow 1: Onboard New Students

```ruby
# Create multiple students from CSV or array
new_students = [
  ["John Doe", 8, 7, 9, 8],
  ["Jane Smith", 9, 8, 9, 10],
  ["Bob Wilson", 7, 7, 8, 7]
]

new_students.each do |name, reading, writing, listening, speaking|
  student = Student.new(
    name: name,
    reading: reading,
    writing: writing,
    listening: listening,
    speaking: speaking
  )
  student.total_score = reading + writing + listening + speaking
  student.percentage = (student.total_score / 40.0) * 100
  
  if student.save
    puts "✓ Created: #{name}"
    # Add initial note
    student.notes.create(content: "New student enrolled")
  else
    puts "✗ Error creating #{name}: #{student.errors.full_messages.join(', ')}"
  end
end
```

---

### Workflow 2: Progress Tracking

```ruby
student = Student.find_by(name: "John Doe")

# Add progress note
student.notes.create(
  content: "Week 1: Shows improvement in listening comprehension. Completed exercises 1-5."
)

# Update scores after assessment
student.update(
  reading: 9,
  writing: 8,
  listening: 10,
  speaking: 9
)

# Add assessment note
student.notes.create(
  content: "Assessment completed. Reading +1, Writing +1, Listening +1, Speaking +1. Great progress!"
)

# View progress
puts "#{student.name}:"
puts "Current Score: #{student.total_score}/40 (#{student.percentage}%)"
puts "\nNotes:"
student.notes.order(created_at: :desc).each do |note|
  puts "#{note.created_at.strftime('%Y-%m-%d')}: #{note.content}"
end
```

---

### Workflow 3: Generate Reports

```ruby
# Performance Report
def performance_report
  puts "=" * 60
  puts "STUDENT PERFORMANCE REPORT"
  puts "=" * 60
  puts
  
  puts "Total Students: #{Student.count}"
  puts "Average Percentage: #{Student.average(:percentage).round(2)}%"
  puts
  
  puts "HIGH PERFORMERS (80%+):"
  Student.where('percentage >= ?', 80).order(percentage: :desc).each do |s|
    puts "  #{s.name.ljust(20)} #{s.percentage.round(1)}%"
  end
  puts
  
  puts "MEDIUM PERFORMERS (60-79%):"
  Student.where(percentage: 60..79).order(percentage: :desc).each do |s|
    puts "  #{s.name.ljust(20)} #{s.percentage.round(1)}%"
  end
  puts
  
  puts "NEED IMPROVEMENT (<60%):"
  Student.where('percentage < ?', 60).order(percentage: :desc).each do |s|
    puts "  #{s.name.ljust(20)} #{s.percentage.round(1)}%"
  end
  puts "=" * 60
end

performance_report
```

---

### Workflow 4: Data Validation

```ruby
# Find invalid or suspicious data
def validate_data
  errors = []
  
  Student.find_each do |student|
    # Check if scores are in valid range
    if student.reading < 0 || student.reading > 10
      errors << "#{student.name}: Invalid reading score"
    end
    
    # Check if calculated fields match
    expected_total = student.reading + student.writing + student.listening + student.speaking
    if student.total_score != expected_total
      errors << "#{student.name}: Total score mismatch"
    end
    
    expected_percentage = (expected_total / 40.0) * 100
    if (student.percentage - expected_percentage).abs > 0.1
      errors << "#{student.name}: Percentage mismatch"
    end
  end
  
  if errors.empty?
    puts "✓ All data is valid!"
  else
    puts "✗ Found #{errors.count} errors:"
    errors.each { |e| puts "  - #{e}" }
  end
end

validate_data
```

---

## Tips and Tricks

### 1. Use Scopes for Common Queries

Add to `student.rb`:

```ruby
class Student < ApplicationRecord
  # ... existing code ...
  
  scope :high_performers, -> { where('percentage >= ?', 80) }
  scope :need_improvement, -> { where('percentage < ?', 60) }
  scope :by_performance, -> { order(percentage: :desc) }
  scope :recent, -> { where('created_at >= ?', 7.days.ago) }
end
```

Usage:
```ruby
Student.high_performers.by_performance
Student.need_improvement.recent
```

---

### 2. Batch Processing

For large datasets, use `find_each`:

```ruby
# Bad: Loads all records into memory
Student.all.each do |student|
  # process
end

# Good: Loads in batches
Student.find_each(batch_size: 100) do |student|
  # process
end
```

---

### 3. Avoid N+1 Queries

```ruby
# Bad: Triggers query for each student's notes
students = Student.all
students.each do |student|
  puts student.notes.count  # N+1 query!
end

# Good: Eager load associations
students = Student.includes(:notes)
students.each do |student|
  puts student.notes.count  # No extra query
end
```

---

### 4. Transaction for Multiple Operations

```ruby
ActiveRecord::Base.transaction do
  student = Student.create!(name: "Test", reading: 8, writing: 7, listening: 9, speaking: 8)
  student.notes.create!(content: "Initial note")
  student.notes.create!(content: "Second note")
end
# All succeed or all rollback
```

---

### 5. Validation Helpers

```ruby
# Check if valid before saving
student = Student.new(name: "Test")
if student.valid?
  student.save
else
  puts student.errors.full_messages
end

# Save with error handling
student = Student.new(student_params)
if student.save
  # Success
else
  # Handle errors
  student.errors.each do |error|
    puts "#{error.attribute}: #{error.message}"
  end
end
```

---

### 6. Export Data

```ruby
require 'csv'

# Export to CSV
CSV.open("students.csv", "w") do |csv|
  csv << ["Name", "Reading", "Writing", "Listening", "Speaking", "Total", "Percentage"]
  
  Student.find_each do |student|
    csv << [
      student.name,
      student.reading,
      student.writing,
      student.listening,
      student.speaking,
      student.total_score,
      student.percentage.round(2)
    ]
  end
end

puts "Exported to students.csv"
```

---

### 7. Import Data

```ruby
require 'csv'

CSV.foreach("students.csv", headers: true) do |row|
  student = Student.new(
    name: row["Name"],
    reading: row["Reading"].to_i,
    writing: row["Writing"].to_i,
    listening: row["Listening"].to_i,
    speaking: row["Speaking"].to_i
  )
  student.total_score = student.reading + student.writing + student.listening + student.speaking
  student.percentage = (student.total_score / 40.0) * 100
  student.save
end
```

---

### 8. Seed Data for Testing

Add to `db/seeds.rb`:

```ruby
puts "Creating students..."

students_data = [
  { name: "Alice Johnson", reading: 9, writing: 8, listening: 9, speaking: 10 },
  { name: "Bob Smith", reading: 7, writing: 7, listening: 8, speaking: 7 },
  { name: "Charlie Brown", reading: 8, writing: 9, listening: 8, speaking: 9 },
  { name: "Diana Prince", reading: 10, writing: 9, listening: 10, speaking: 10 },
  { name: "Eve Wilson", reading: 6, writing: 6, listening: 7, speaking: 6 }
]

students_data.each do |data|
  student = Student.new(data)
  student.total_score = student.reading + student.writing + student.listening + student.speaking
  student.percentage = (student.total_score / 40.0) * 100
  student.save!
  
  # Add sample notes
  student.notes.create!(content: "Initial assessment completed")
  student.notes.create!(content: "Student shows #{student.percentage >= 80 ? 'excellent' : 'good'} potential")
  
  puts "Created: #{student.name}"
end

puts "Done! Created #{Student.count} students with #{Note.count} notes."
```

Run with: `rails db:seed`

---

## Quick Reference

### URL Patterns

| Action | URL Pattern |
|--------|-------------|
| List all students | `/students` |
| New student form | `/students/new` |
| Create student | `POST /students` |
| Show student | `/students/:id` |
| Edit student form | `/students/:id/edit` |
| Update student | `PATCH /students/:id` |
| Delete student | `DELETE /students/:id` |
| List notes | `/students/:student_id/notes` |
| New note form | `/students/:student_id/notes/new` |
| Create note | `POST /students/:student_id/notes` |
| Show note | `/students/:student_id/notes/:id` |
| Edit note | `/students/:student_id/notes/:id/edit` |
| Update note | `PATCH /students/:student_id/notes/:id` |
| Delete note | `DELETE /students/:student_id/notes/:id` |

### Console Quick Commands

```ruby
# Open console
rails console

# Find records
Student.find(1)
Student.find_by(name: "John")
Student.where(percentage: 80..100)
Student.all
Student.first / Student.last

# Create
Student.create(name: "Test", reading: 8, writing: 7, listening: 9, speaking: 8)

# Update
student.update(reading: 10)

# Delete
student.destroy

# Reload from database
student.reload

# Exit console
exit
```

---

For more detailed API documentation, see [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)