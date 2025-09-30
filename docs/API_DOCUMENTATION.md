# Student Management System - API Documentation

## Overview

This is a Ruby on Rails application for managing students and their associated notes. The system tracks student language proficiency scores across four categories: reading, writing, listening, and speaking.

## Base URL

```
http://localhost:3000
```

## Authentication

Currently, this application does not implement authentication. All endpoints are publicly accessible.

## Data Models

### Student

Represents a student with language proficiency scores.

**Attributes:**
- `id` (integer) - Unique identifier
- `name` (string) - Student's name (required)
- `reading` (integer) - Reading score (0-10, required)
- `writing` (integer) - Writing score (0-10, required)
- `listening` (integer) - Listening score (0-10, required)
- `speaking` (integer) - Speaking score (0-10, required)
- `total_score` (integer) - Calculated sum of all scores (auto-calculated)
- `percentage` (float) - Percentage score out of 100 (auto-calculated)
- `created_at` (datetime) - Record creation timestamp
- `updated_at` (datetime) - Record last update timestamp

**Validations:**
- `name`: Must be present
- `reading`, `writing`, `listening`, `speaking`: Must be present and between 0-10

**Relationships:**
- `has_many :notes` (dependent: destroy)

### Note

Represents a note associated with a student.

**Attributes:**
- `id` (integer) - Unique identifier
- `content` (text) - Note content (required, 1-1000 characters)
- `student_id` (integer) - Foreign key to student (required)
- `created_at` (datetime) - Record creation timestamp
- `updated_at` (datetime) - Record last update timestamp

**Validations:**
- `content`: Must be present, minimum 1 character, maximum 1000 characters

**Relationships:**
- `belongs_to :student`

## API Endpoints

### Students API

#### GET /students
Lists all students ordered by percentage score (highest first).

**Response:**
```json
{
  "students": [
    {
      "id": 1,
      "name": "John Doe",
      "reading": 8,
      "writing": 7,
      "listening": 9,
      "speaking": 8,
      "total_score": 32,
      "percentage": 80.0,
      "created_at": "2025-09-30T10:00:00Z",
      "updated_at": "2025-09-30T10:00:00Z"
    }
  ]
}
```

#### GET /students/:id
Retrieves a specific student by ID.

**Parameters:**
- `id` (integer, required) - Student ID

**Response:**
```json
{
  "id": 1,
  "name": "John Doe",
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

#### POST /students
Creates a new student.

**Request Body:**
```json
{
  "student": {
    "name": "Jane Smith",
    "reading": 9,
    "writing": 8,
    "listening": 7,
    "speaking": 9
  }
}
```

**Response (Success - 201 Created):**
```json
{
  "id": 2,
  "name": "Jane Smith",
  "reading": 9,
  "writing": 8,
  "listening": 7,
  "speaking": 9,
  "total_score": 33,
  "percentage": 82.5,
  "created_at": "2025-09-30T10:30:00Z",
  "updated_at": "2025-09-30T10:30:00Z"
}
```

**Response (Error - 422 Unprocessable Entity):**
```json
{
  "errors": {
    "name": ["can't be blank"],
    "reading": ["must be between 0 and 10"]
  }
}
```

#### PUT/PATCH /students/:id
Updates an existing student.

**Parameters:**
- `id` (integer, required) - Student ID

**Request Body:**
```json
{
  "student": {
    "name": "John Doe Updated",
    "reading": 9,
    "writing": 8,
    "listening": 9,
    "speaking": 8
  }
}
```

**Response (Success - 200 OK):**
```json
{
  "id": 1,
  "name": "John Doe Updated",
  "reading": 9,
  "writing": 8,
  "listening": 9,
  "speaking": 8,
  "total_score": 34,
  "percentage": 85.0,
  "created_at": "2025-09-30T10:00:00Z",
  "updated_at": "2025-09-30T11:00:00Z"
}
```

#### DELETE /students/:id
Deletes a student and all associated notes.

**Parameters:**
- `id` (integer, required) - Student ID

**Response (Success - 200 OK):**
```json
{
  "message": "Student successfully deleted"
}
```

### Notes API

#### GET /students/:student_id/notes
Lists all notes for a specific student, ordered by creation date (newest first).

**Parameters:**
- `student_id` (integer, required) - Student ID

**Response:**
```json
{
  "notes": [
    {
      "id": 1,
      "content": "Student shows improvement in speaking skills.",
      "student_id": 1,
      "created_at": "2025-09-30T10:15:00Z",
      "updated_at": "2025-09-30T10:15:00Z"
    }
  ]
}
```

#### GET /students/:student_id/notes/:id
Retrieves a specific note.

**Parameters:**
- `student_id` (integer, required) - Student ID
- `id` (integer, required) - Note ID

**Response:**
```json
{
  "id": 1,
  "content": "Student shows improvement in speaking skills.",
  "student_id": 1,
  "created_at": "2025-09-30T10:15:00Z",
  "updated_at": "2025-09-30T10:15:00Z"
}
```

#### POST /students/:student_id/notes
Creates a new note for a student.

**Parameters:**
- `student_id` (integer, required) - Student ID

**Request Body:**
```json
{
  "note": {
    "content": "Student needs more practice with listening comprehension."
  }
}
```

**Response (Success - 201 Created):**
```json
{
  "id": 2,
  "content": "Student needs more practice with listening comprehension.",
  "student_id": 1,
  "created_at": "2025-09-30T11:00:00Z",
  "updated_at": "2025-09-30T11:00:00Z"
}
```

#### PUT/PATCH /students/:student_id/notes/:id
Updates an existing note.

**Parameters:**
- `student_id` (integer, required) - Student ID
- `id` (integer, required) - Note ID

**Request Body:**
```json
{
  "note": {
    "content": "Updated note content here."
  }
}
```

**Response (Success - 200 OK):**
```json
{
  "id": 1,
  "content": "Updated note content here.",
  "student_id": 1,
  "created_at": "2025-09-30T10:15:00Z",
  "updated_at": "2025-09-30T11:30:00Z"
}
```

#### DELETE /students/:student_id/notes/:id
Deletes a specific note.

**Parameters:**
- `student_id` (integer, required) - Student ID
- `id` (integer, required) - Note ID

**Response (Success - 200 OK):**
```json
{
  "message": "Note successfully deleted"
}
```

## Error Responses

### Common HTTP Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors
- `500 Internal Server Error` - Server error

### Error Response Format

```json
{
  "errors": {
    "field_name": ["error message 1", "error message 2"]
  }
}
```

## Rate Limiting

Currently, no rate limiting is implemented.

## Pagination

Currently, no pagination is implemented. All records are returned in a single response.