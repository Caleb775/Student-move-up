# Usage Examples and Code Samples

## Overview

This document provides practical usage examples, code samples, and common use cases for the Student Management System. All examples include both programmatic and HTTP API usage.

## Table of Contents

1. [Student Management Examples](#student-management-examples)
2. [Note Management Examples](#note-management-examples)
3. [API Integration Examples](#api-integration-examples)
4. [Rails Console Examples](#rails-console-examples)
5. [Testing Examples](#testing-examples)
6. [Common Use Cases](#common-use-cases)

---

## Student Management Examples

### Creating Students

#### Via Web Interface

1. Navigate to `/students/new`
2. Fill out the form:
   - Name: "Alice Johnson"
   - Reading: 8
   - Writing: 7
   - Listening: 9
   - Speaking: 8
3. Submit the form
4. System automatically calculates:
   - Total Score: 32
   - Percentage: 80.0%

#### Via Rails Console

```ruby
# Create a new student
student = Student.new(
  name: "Alice Johnson",
  reading: 8,
  writing: 7,
  listening: 9,
  speaking: 8
)

# Validate before saving
if student.valid?
  # Calculate scores (normally done in controller)
  student.total_score = student.reading + student.writing + student.listening + student.speaking
  student.percentage = (student.total_score / 40.0) * 100
  
  student.save!
  puts "Student created: #{student.name} (#{student.percentage}%)"
else
  puts "Validation errors: #{student.errors.full_messages}"
end
```

#### Via HTTP API

```bash
# Create student via cURL
curl -X POST http://localhost:3000/students \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "student": {
      "name": "Alice Johnson",
      "reading": 8,
      "writing": 7,
      "listening": 9,
      "speaking": 8
    }
  }'
```

**Response:**
```json
{
  "id": 1,
  "name": "Alice Johnson",
  "reading": 8,
  "writing": 7,
  "listening": 9,
  "speaking": 8,
  "total_score": 32,
  "percentage": 80.0,
  "created_at": "2025-09-30T10:00:00Z",
  "updated_at": "2025-09-30T10:00:00Z"
}
```

### Updating Students

#### Via Web Interface

1. Navigate to `/students/1/edit`
2. Update scores:
   - Reading: 9 (improved from 8)
   - Writing: 8 (improved from 7)
3. Submit the form
4. System recalculates scores automatically

#### Via Rails Console

```ruby
# Find and update student
student = Student.find(1)
student.assign_attributes(reading: 9, writing: 8)

# Recalculate scores
student.total_score = student.reading + student.writing + student.listening + student.speaking
student.percentage = (student.total_score / 40.0) * 100

if student.save
  puts "Student updated: #{student.name} now has #{student.percentage}% (#{student.total_score}/40)"
else
  puts "Update failed: #{student.errors.full_messages}"
end
```

#### Via HTTP API

```bash
# Update student via cURL
curl -X PATCH http://localhost:3000/students/1 \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "student": {
      "reading": 9,
      "writing": 8
    }
  }'
```

### Querying Students

#### Find Top Performers

```ruby
# Rails Console
top_students = Student.where('percentage >= ?', 80.0)
                     .order(percentage: :desc)
                     .limit(10)

top_students.each do |student|
  puts "#{student.name}: #{student.percentage}% (#{student.total_score}/40)"
end
```

#### Find Students by Score Range

```ruby
# Find students with specific total score range
mid_range_students = Student.where(total_score: 20..30)
                           .order(:name)

puts "Students with scores between 20-30:"
mid_range_students.each do |student|
  puts "- #{student.name}: #{student.total_score}/40"
end
```

#### Get Student Statistics

```ruby
# Calculate class statistics
stats = {
  total_students: Student.count,
  average_percentage: Student.average(:percentage).round(2),
  highest_score: Student.maximum(:total_score),
  lowest_score: Student.minimum(:total_score),
  top_performer: Student.order(percentage: :desc).first&.name
}

puts "Class Statistics:"
stats.each { |key, value| puts "#{key.to_s.humanize}: #{value}" }
```

---

## Note Management Examples

### Creating Notes

#### Via Web Interface

1. Navigate to `/students/1` (student show page)
2. Click "Add Note"
3. Enter note content: "Student shows excellent improvement in pronunciation"
4. Submit the form

#### Via Rails Console

```ruby
# Find student and create note
student = Student.find(1)
note = student.notes.create!(
  content: "Student shows excellent improvement in pronunciation. " \
           "Recommend continuing with current study plan."
)

puts "Note created for #{student.name}: #{note.content[0..50]}..."
```

#### Via HTTP API

```bash
# Create note via cURL
curl -X POST http://localhost:3000/students/1/notes \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "note": {
      "content": "Student shows excellent improvement in pronunciation."
    }
  }'
```

### Bulk Note Operations

#### Add Notes for Multiple Students

```ruby
# Add progress notes for all students above 75%
high_performers = Student.where('percentage >= ?', 75.0)

high_performers.each do |student|
  student.notes.create!(
    content: "Excellent performance! Current score: #{student.percentage}%. " \
             "Continue with advanced materials."
  )
end

puts "Added progress notes for #{high_performers.count} high-performing students"
```

#### Generate Weekly Summary Notes

```ruby
# Generate weekly summary for all students
Student.includes(:notes).each do |student|
  recent_notes_count = student.notes.where('created_at >= ?', 1.week.ago).count
  
  summary = "Weekly Summary: #{student.name} (#{student.percentage}%) - " \
            "#{recent_notes_count} notes this week."
  
  student.notes.create!(content: summary)
end
```

---

## API Integration Examples

### JavaScript/AJAX Integration

#### Fetch Student Data

```javascript
// Fetch student with notes
async function fetchStudent(studentId) {
  try {
    const response = await fetch(`/students/${studentId}`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const student = await response.json();
    console.log('Student data:', student);
    return student;
  } catch (error) {
    console.error('Error fetching student:', error);
  }
}

// Usage
fetchStudent(1).then(student => {
  document.getElementById('student-name').textContent = student.name;
  document.getElementById('student-score').textContent = `${student.percentage}%`;
});
```

#### Update Student Scores Dynamically

```javascript
// Update student scores with real-time calculation
async function updateStudentScores(studentId, scores) {
  const { reading, writing, listening, speaking } = scores;
  
  try {
    const response = await fetch(`/students/${studentId}`, {
      method: 'PATCH',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        student: { reading, writing, listening, speaking }
      })
    });
    
    const updatedStudent = await response.json();
    
    // Update UI with new scores
    document.getElementById('total-score').textContent = updatedStudent.total_score;
    document.getElementById('percentage').textContent = `${updatedStudent.percentage}%`;
    
    return updatedStudent;
  } catch (error) {
    console.error('Error updating student:', error);
  }
}

// Usage with form
document.getElementById('student-form').addEventListener('input', (event) => {
  const form = event.target.form;
  const formData = new FormData(form);
  
  const scores = {
    reading: parseInt(formData.get('student[reading]')) || 0,
    writing: parseInt(formData.get('student[writing]')) || 0,
    listening: parseInt(formData.get('student[listening]')) || 0,
    speaking: parseInt(formData.get('student[speaking]')) || 0
  };
  
  // Calculate and display preview
  const total = scores.reading + scores.writing + scores.listening + scores.speaking;
  const percentage = (total / 40) * 100;
  
  document.getElementById('score-preview').textContent = 
    `Total: ${total}/40 (${percentage.toFixed(1)}%)`;
});
```

### Python Integration Example

```python
import requests
import json

class StudentAPI:
    def __init__(self, base_url="http://localhost:3000"):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
    
    def create_student(self, name, reading, writing, listening, speaking):
        """Create a new student"""
        data = {
            "student": {
                "name": name,
                "reading": reading,
                "writing": writing,
                "listening": listening,
                "speaking": speaking
            }
        }
        
        response = self.session.post(f"{self.base_url}/students", json=data)
        response.raise_for_status()
        return response.json()
    
    def get_student(self, student_id):
        """Get student by ID"""
        response = self.session.get(f"{self.base_url}/students/{student_id}")
        response.raise_for_status()
        return response.json()
    
    def get_all_students(self):
        """Get all students"""
        response = self.session.get(f"{self.base_url}/students")
        response.raise_for_status()
        return response.json()
    
    def add_note(self, student_id, content):
        """Add note to student"""
        data = {"note": {"content": content}}
        response = self.session.post(
            f"{self.base_url}/students/{student_id}/notes", 
            json=data
        )
        response.raise_for_status()
        return response.json()

# Usage example
api = StudentAPI()

# Create student
student = api.create_student(
    name="Bob Wilson",
    reading=7,
    writing=8,
    listening=6,
    speaking=9
)
print(f"Created student: {student['name']} with {student['percentage']}%")

# Add note
note = api.add_note(student['id'], "Student excels in speaking but needs reading practice")
print(f"Added note: {note['content'][:50]}...")
```

---

## Rails Console Examples

### Data Analysis and Reporting

#### Generate Performance Report

```ruby
# Generate comprehensive performance report
def generate_performance_report
  puts "=" * 50
  puts "STUDENT PERFORMANCE REPORT"
  puts "=" * 50
  
  total_students = Student.count
  puts "Total Students: #{total_students}"
  
  if total_students > 0
    avg_percentage = Student.average(:percentage).round(2)
    puts "Average Score: #{avg_percentage}%"
    
    # Score distribution
    excellent = Student.where('percentage >= ?', 90).count
    good = Student.where('percentage >= ? AND percentage < ?', 75, 90).count
    average = Student.where('percentage >= ? AND percentage < ?', 60, 75).count
    needs_improvement = Student.where('percentage < ?', 60).count
    
    puts "\nScore Distribution:"
    puts "Excellent (90%+): #{excellent} students"
    puts "Good (75-89%): #{good} students"
    puts "Average (60-74%): #{average} students"
    puts "Needs Improvement (<60%): #{needs_improvement} students"
    
    # Top performers
    puts "\nTop 5 Performers:"
    Student.order(percentage: :desc).limit(5).each_with_index do |student, index|
      puts "#{index + 1}. #{student.name}: #{student.percentage}%"
    end
    
    # Skill analysis
    puts "\nSkill Averages:"
    puts "Reading: #{Student.average(:reading).round(2)}/10"
    puts "Writing: #{Student.average(:writing).round(2)}/10"
    puts "Listening: #{Student.average(:listening).round(2)}/10"
    puts "Speaking: #{Student.average(:speaking).round(2)}/10"
  end
  
  puts "=" * 50
end

# Run the report
generate_performance_report
```

#### Data Cleanup and Maintenance

```ruby
# Remove duplicate students (by name)
duplicates = Student.select(:name)
                   .group(:name)
                   .having('count(*) > 1')
                   .pluck(:name)

duplicates.each do |name|
  students = Student.where(name: name).order(:created_at)
  puts "Found #{students.count} students named '#{name}'"
  
  # Keep the first one, merge notes from others
  primary = students.first
  students[1..-1].each do |duplicate|
    duplicate.notes.update_all(student_id: primary.id)
    duplicate.destroy
    puts "Merged duplicate student #{duplicate.id} into #{primary.id}"
  end
end
```

#### Bulk Data Operations

```ruby
# Update all students with missing calculated fields
Student.where(total_score: nil).or(Student.where(percentage: nil)).each do |student|
  student.total_score = student.reading + student.writing + student.listening + student.speaking
  student.percentage = (student.total_score / 40.0) * 100
  student.save!
  puts "Updated scores for #{student.name}"
end

# Add welcome notes for new students (those without notes)
students_without_notes = Student.left_joins(:notes)
                               .where(notes: { id: nil })

students_without_notes.each do |student|
  student.notes.create!(
    content: "Welcome to the program! Current assessment: #{student.percentage}%. " \
             "We'll track your progress here."
  )
  puts "Added welcome note for #{student.name}"
end
```

---

## Testing Examples

### Model Testing

```ruby
# test/models/student_test.rb
require "test_helper"

class StudentTest < ActiveSupport::TestCase
  test "should not save student without name" do
    student = Student.new(reading: 8, writing: 7, listening: 9, speaking: 8)
    assert_not student.save, "Saved student without name"
  end
  
  test "should not save student with invalid scores" do
    student = Student.new(name: "Test", reading: 11, writing: 7, listening: 9, speaking: 8)
    assert_not student.save, "Saved student with score > 10"
    
    student.reading = -1
    assert_not student.save, "Saved student with negative score"
  end
  
  test "should calculate scores correctly" do
    student = students(:alice) # fixture
    expected_total = student.reading + student.writing + student.listening + student.speaking
    expected_percentage = (expected_total / 40.0) * 100
    
    # Simulate controller calculation
    student.total_score = expected_total
    student.percentage = expected_percentage
    
    assert_equal expected_total, student.total_score
    assert_equal expected_percentage, student.percentage
  end
  
  test "should destroy associated notes when student is destroyed" do
    student = students(:alice)
    note_count = student.notes.count
    assert note_count > 0, "Student should have notes for this test"
    
    assert_difference('Note.count', -note_count) do
      student.destroy
    end
  end
end
```

### Controller Testing

```ruby
# test/controllers/students_controller_test.rb
require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = students(:alice)
  end
  
  test "should get index" do
    get students_url
    assert_response :success
    assert_select "h1", "Students"
  end
  
  test "should create student with valid attributes" do
    assert_difference('Student.count') do
      post students_url, params: {
        student: {
          name: "New Student",
          reading: 8,
          writing: 7,
          listening: 9,
          speaking: 8
        }
      }
    end
    
    assert_redirected_to student_url(Student.last)
    
    # Verify scores were calculated
    new_student = Student.last
    assert_equal 32, new_student.total_score
    assert_equal 80.0, new_student.percentage
  end
  
  test "should not create student with invalid attributes" do
    assert_no_difference('Student.count') do
      post students_url, params: {
        student: {
          name: "",
          reading: 11,
          writing: 7,
          listening: 9,
          speaking: 8
        }
      }
    end
    
    assert_response :unprocessable_entity
  end
  
  test "should update student and recalculate scores" do
    patch student_url(@student), params: {
      student: {
        reading: 10,
        writing: 9
      }
    }
    
    assert_redirected_to student_url(@student)
    
    @student.reload
    expected_total = 10 + 9 + @student.listening + @student.speaking
    expected_percentage = (expected_total / 40.0) * 100
    
    assert_equal expected_total, @student.total_score
    assert_equal expected_percentage, @student.percentage
  end
end
```

### System Testing

```ruby
# test/system/students_test.rb
require "application_system_test_case"

class StudentsTest < ApplicationSystemTestCase
  test "creating a student" do
    visit students_path
    click_on "New Student"
    
    fill_in "Name", with: "System Test Student"
    fill_in "Reading", with: "8"
    fill_in "Writing", with: "7"
    fill_in "Listening", with: "9"
    fill_in "Speaking", with: "8"
    
    click_on "Create Student"
    
    assert_text "Student successfully created"
    assert_text "System Test Student"
    assert_text "80.0%" # Calculated percentage
  end
  
  test "adding a note to student" do
    student = students(:alice)
    visit student_path(student)
    
    click_on "Add Note"
    fill_in "Content", with: "This is a test note for system testing"
    click_on "Create Note"
    
    assert_text "Note was successfully created"
    assert_text "This is a test note for system testing"
  end
end
```

---

## Common Use Cases

### Student Onboarding Workflow

```ruby
# Complete student onboarding process
def onboard_student(name, initial_scores, welcome_message = nil)
  # Create student
  student = Student.new(
    name: name,
    reading: initial_scores[:reading],
    writing: initial_scores[:writing],
    listening: initial_scores[:listening],
    speaking: initial_scores[:speaking]
  )
  
  # Calculate scores
  student.total_score = initial_scores.values.sum
  student.percentage = (student.total_score / 40.0) * 100
  
  if student.save
    # Add welcome note
    welcome_text = welcome_message || 
      "Welcome to our language program! Your initial assessment shows " \
      "#{student.percentage}% proficiency. We'll track your progress here."
    
    student.notes.create!(content: welcome_text)
    
    puts "Successfully onboarded #{student.name} (#{student.percentage}%)"
    student
  else
    puts "Onboarding failed: #{student.errors.full_messages.join(', ')}"
    nil
  end
end

# Usage
new_student = onboard_student(
  "Maria Garcia",
  { reading: 7, writing: 6, listening: 8, speaking: 9 },
  "¡Bienvenida! Your speaking skills are excellent. Let's work on writing together."
)
```

### Progress Tracking

```ruby
# Track student progress over time
def track_progress(student_id, new_scores, progress_note)
  student = Student.find(student_id)
  old_percentage = student.percentage
  
  # Update scores
  student.assign_attributes(new_scores)
  student.total_score = student.reading + student.writing + student.listening + student.speaking
  student.percentage = (student.total_score / 40.0) * 100
  
  if student.save
    # Calculate improvement
    improvement = student.percentage - old_percentage
    
    # Add progress note
    note_content = "Progress Update: #{progress_note}\n\n" \
                   "Score change: #{old_percentage.round(1)}% → #{student.percentage.round(1)}% " \
                   "(#{improvement > 0 ? '+' : ''}#{improvement.round(1)}%)"
    
    student.notes.create!(content: note_content)
    
    puts "Progress tracked for #{student.name}: #{improvement.round(1)}% change"
    { student: student, improvement: improvement }
  else
    puts "Progress tracking failed: #{student.errors.full_messages.join(', ')}"
    nil
  end
end

# Usage
progress_result = track_progress(
  1,
  { reading: 9, writing: 8 }, # Improved scores
  "Excellent improvement in reading comprehension after completing advanced materials."
)
```

### Batch Operations

```ruby
# Process multiple students at once
def batch_update_students(updates_hash)
  results = { success: [], failed: [] }
  
  updates_hash.each do |student_id, update_data|
    begin
      student = Student.find(student_id)
      
      if update_data[:scores]
        student.assign_attributes(update_data[:scores])
        student.total_score = student.reading + student.writing + student.listening + student.speaking
        student.percentage = (student.total_score / 40.0) * 100
      end
      
      if student.save
        # Add batch update note if provided
        if update_data[:note]
          student.notes.create!(content: "Batch Update: #{update_data[:note]}")
        end
        
        results[:success] << { id: student_id, name: student.name }
      else
        results[:failed] << { id: student_id, errors: student.errors.full_messages }
      end
      
    rescue ActiveRecord::RecordNotFound
      results[:failed] << { id: student_id, errors: ["Student not found"] }
    end
  end
  
  puts "Batch update completed: #{results[:success].count} successful, #{results[:failed].count} failed"
  results
end

# Usage
batch_results = batch_update_students({
  1 => { 
    scores: { reading: 9, writing: 8 },
    note: "Mid-semester assessment update"
  },
  2 => {
    scores: { listening: 8, speaking: 9 },
    note: "Oral skills improvement noted"
  }
})
```

These examples demonstrate the full range of functionality available in the Student Management System, from basic CRUD operations to complex batch processing and API integrations.