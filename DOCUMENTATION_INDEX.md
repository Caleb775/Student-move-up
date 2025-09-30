# Documentation Index

Complete documentation for the Student Language Proficiency Tracker application.

## 📚 Documentation Files

### 1. [README.md](./README.md)
**Main project documentation** - Start here!

- Installation and setup instructions
- Quick start guide  
- Running the application
- Testing and deployment
- Technology stack overview
- Project structure

**Best for**: Getting the application up and running, understanding the project architecture.

---

### 2. [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
**Complete API Reference**

- All models (Student, Note) with schemas and examples
- All controllers (Students, Notes) with routes and endpoints
- Request/response formats
- Validation rules and error handling
- Code examples for every operation
- Database schema

**Best for**: Developers integrating with the API, understanding data structures and endpoints.

---

### 3. [USAGE_GUIDE.md](./USAGE_GUIDE.md)
**Practical usage examples and workflows**

- Step-by-step student management
- Note management workflows
- Advanced database queries
- Rails console examples
- Common workflows (reports, bulk operations)
- Tips and tricks
- Import/export data

**Best for**: Day-to-day usage, learning Rails console commands, practical examples.

---

### 4. [JAVASCRIPT_DOCUMENTATION.md](./JAVASCRIPT_DOCUMENTATION.md)
**Frontend JavaScript documentation**

- Stimulus controllers explained
- Turbo features (Drive, Frames, Streams)
- Creating custom controllers
- Usage examples
- Best practices
- Debugging tips

**Best for**: Frontend developers, adding JavaScript interactivity, understanding Hotwire.

---

## 🎯 Quick Navigation

### I want to...

#### Install and Run the Application
→ See [README.md - Installation](./README.md#installation)

#### Understand the API Endpoints
→ See [API_DOCUMENTATION.md - Routes](./API_DOCUMENTATION.md#controllers--routes)

#### Create/Update Students via Code
→ See [USAGE_GUIDE.md - Student Management](./USAGE_GUIDE.md#student-management)

#### Add JavaScript Functionality
→ See [JAVASCRIPT_DOCUMENTATION.md - Creating Controllers](./JAVASCRIPT_DOCUMENTATION.md#creating-custom-controllers)

#### Learn Database Queries
→ See [USAGE_GUIDE.md - Advanced Queries](./USAGE_GUIDE.md#advanced-queries)

#### Understand the Models
→ See [API_DOCUMENTATION.md - Models](./API_DOCUMENTATION.md#models)

#### Deploy to Production
→ See [README.md - Deployment](./README.md#deployment)

#### Run Tests
→ See [README.md - Testing](./README.md#testing)

---

## 📖 Documentation by Role

### For New Developers

1. **Start**: [README.md](./README.md) - Installation and setup
2. **Understand**: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) - Models and controllers
3. **Practice**: [USAGE_GUIDE.md](./USAGE_GUIDE.md) - Rails console examples
4. **Enhance**: [JAVASCRIPT_DOCUMENTATION.md](./JAVASCRIPT_DOCUMENTATION.md) - Add interactivity

### For API Consumers

1. **Routes**: [API_DOCUMENTATION.md - Routes](./API_DOCUMENTATION.md#controllers--routes)
2. **Request Format**: [API_DOCUMENTATION.md - Examples](./API_DOCUMENTATION.md#api-examples)
3. **Error Handling**: [API_DOCUMENTATION.md - Errors](./API_DOCUMENTATION.md#error-handling)

### For Frontend Developers

1. **JavaScript Setup**: [JAVASCRIPT_DOCUMENTATION.md - Overview](./JAVASCRIPT_DOCUMENTATION.md#overview)
2. **Stimulus**: [JAVASCRIPT_DOCUMENTATION.md - Controllers](./JAVASCRIPT_DOCUMENTATION.md#stimulus-controllers)
3. **Turbo**: [JAVASCRIPT_DOCUMENTATION.md - Turbo Features](./JAVASCRIPT_DOCUMENTATION.md#turbo-features)

### For DevOps/Deployment

1. **Prerequisites**: [README.md - Prerequisites](./README.md#prerequisites)
2. **Configuration**: [README.md - Configuration](./README.md#configuration)
3. **Deployment**: [README.md - Deployment](./README.md#deployment)
4. **Troubleshooting**: [README.md - Troubleshooting](./README.md#troubleshooting)

---

## 🔍 Key Concepts

### Models

**Student Model**
- Tracks language proficiency scores (reading, writing, listening, speaking)
- Auto-calculates total score and percentage
- Has many notes (cascade delete)
- Validation: all scores 0-10, name required

**Note Model**
- Belongs to a student
- Stores observations and comments
- Validation: 1-1000 characters

📄 [Full Model Documentation](./API_DOCUMENTATION.md#models)

---

### Controllers

**StudentsController**
- CRUD operations for students
- Auto-calculates scores before saving
- Routes: `/students`, `/students/:id`, etc.

**NotesController**  
- CRUD operations for notes
- Scoped to parent student
- Routes: `/students/:student_id/notes`, etc.

📄 [Full Controller Documentation](./API_DOCUMENTATION.md#controllers--routes)

---

### JavaScript

**Hotwire Stack**
- Turbo Drive: Fast page navigation
- Turbo Frames: Partial page updates
- Stimulus: JavaScript behavior controllers

**Controllers**
- `hello_controller.js`: Example controller
- Custom controllers: Add as needed

📄 [Full JavaScript Documentation](./JAVASCRIPT_DOCUMENTATION.md)

---

## 📋 Common Tasks Reference

### Setup Tasks

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Seed sample data
rails db:seed

# Run server
rails server
```

📄 [Full Setup Guide](./README.md#installation)

---

### CRUD Operations

#### Students

```ruby
# Create
student = Student.create(name: "John", reading: 8, writing: 7, listening: 9, speaking: 8)

# Read
Student.find(1)
Student.all

# Update
student.update(reading: 10)

# Delete
student.destroy
```

📄 [Full CRUD Examples](./USAGE_GUIDE.md#student-management)

#### Notes

```ruby
# Create
student.notes.create(content: "Great progress!")

# Read
student.notes.all

# Update
note.update(content: "Updated content")

# Delete
note.destroy
```

📄 [Full Note Examples](./USAGE_GUIDE.md#note-management)

---

### Common Queries

```ruby
# Top performers
Student.order(percentage: :desc).limit(10)

# High performers (80%+)
Student.where('percentage >= ?', 80)

# Search by name
Student.where('name ILIKE ?', '%john%')

# With notes
Student.includes(:notes)
```

📄 [Full Query Examples](./USAGE_GUIDE.md#advanced-queries)

---

## 🛠️ Code Examples

### Example 1: Complete Student Workflow

```ruby
# Create student
student = Student.create(
  name: "Alice Johnson",
  reading: 9,
  writing: 8, 
  listening: 9,
  speaking: 10
)

# Add notes
student.notes.create(content: "Excellent pronunciation")
student.notes.create(content: "Strong comprehension skills")

# Update scores
student.update(reading: 10)

# View results
puts "#{student.name}: #{student.percentage}%"
student.notes.each { |note| puts "- #{note.content}" }
```

📄 [More Workflows](./USAGE_GUIDE.md#common-workflows)

---

### Example 2: Add JavaScript Interactivity

**Controller** (`app/javascript/controllers/score_controller.js`):
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["total", "percentage"]
  
  calculate() {
    // calculation logic
  }
}
```

**HTML**:
```html
<div data-controller="score">
  <input data-action="input->score#calculate">
  <span data-score-target="total"></span>
</div>
```

📄 [Full JavaScript Examples](./JAVASCRIPT_DOCUMENTATION.md#usage-examples)

---

## 📊 Database Schema

### Students Table

| Column | Type | Description |
|--------|------|-------------|
| id | integer | Primary key |
| name | string | Student name |
| reading | integer | Reading score (0-10) |
| writing | integer | Writing score (0-10) |
| listening | integer | Listening score (0-10) |
| speaking | integer | Speaking score (0-10) |
| total_score | integer | Sum of all scores |
| percentage | float | Percentage (0-100) |
| created_at | datetime | Creation timestamp |
| updated_at | datetime | Update timestamp |

### Notes Table

| Column | Type | Description |
|--------|------|-------------|
| id | integer | Primary key |
| content | text | Note content |
| student_id | integer | Foreign key |
| created_at | datetime | Creation timestamp |
| updated_at | datetime | Update timestamp |

📄 [Full Schema Documentation](./API_DOCUMENTATION.md#database-schema)

---

## 🌐 API Endpoints

### Student Endpoints

| Method | Path | Action |
|--------|------|--------|
| GET | `/students` | List all |
| POST | `/students` | Create |
| GET | `/students/:id` | Show |
| PATCH | `/students/:id` | Update |
| DELETE | `/students/:id` | Delete |

### Note Endpoints

| Method | Path | Action |
|--------|------|--------|
| GET | `/students/:student_id/notes` | List all |
| POST | `/students/:student_id/notes` | Create |
| GET | `/students/:student_id/notes/:id` | Show |
| PATCH | `/students/:student_id/notes/:id` | Update |
| DELETE | `/students/:student_id/notes/:id` | Delete |

📄 [Full API Reference](./API_DOCUMENTATION.md#controllers--routes)

---

## 🔐 Security & Validation

### Student Validations
- Name: required
- Reading, Writing, Listening, Speaking: required, 0-10

### Note Validations
- Content: required, 1-1000 characters

### Security Features
- Strong parameters (mass assignment protection)
- CSRF protection
- SQL injection prevention
- Foreign key constraints

📄 [Full Validation Rules](./API_DOCUMENTATION.md#validations)

---

## 🧪 Testing

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/student_test.rb

# Run system tests
rails test:system

# Code quality checks
bin/rubocop
bin/brakeman
```

📄 [Full Testing Guide](./README.md#testing)

---

## 🚀 Deployment

### Docker (Kamal)
```bash
kamal setup
kamal deploy
```

### Traditional
```bash
bundle install --without development test
RAILS_ENV=production rails assets:precompile
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails server
```

📄 [Full Deployment Guide](./README.md#deployment)

---

## 🐛 Troubleshooting

### Common Issues

**Database connection errors**
→ [README.md - Troubleshooting](./README.md#troubleshooting)

**Validation failures**
→ [API_DOCUMENTATION.md - Error Handling](./API_DOCUMENTATION.md#error-handling)

**JavaScript not working**
→ [JAVASCRIPT_DOCUMENTATION.md - Debugging](./JAVASCRIPT_DOCUMENTATION.md#debugging)

---

## 📚 Additional Resources

### Technology Documentation

- **Rails**: https://guides.rubyonrails.org
- **PostgreSQL**: https://www.postgresql.org/docs
- **Hotwire**: https://hotwired.dev
- **Stimulus**: https://stimulus.hotwired.dev
- **Turbo**: https://turbo.hotwired.dev

### Project Files

- **Gemfile**: Ruby dependencies
- **config/routes.rb**: URL routing
- **db/schema.rb**: Database structure
- **app/models/**: Data models
- **app/controllers/**: Request handlers
- **app/javascript/**: Frontend code

---

## 📝 Documentation Updates

This documentation is maintained alongside the code. When making changes:

1. Update relevant `.md` files
2. Update inline code comments
3. Add examples for new features
4. Keep documentation in sync with code

---

## 📞 Getting Help

1. **Check the docs**: Start with this index
2. **Search examples**: Look in USAGE_GUIDE.md
3. **Review API**: Check API_DOCUMENTATION.md
4. **Check inline docs**: Look at code comments
5. **Rails console**: Experiment with `rails console`

---

## Summary

| Document | Purpose | Best For |
|----------|---------|----------|
| [README.md](./README.md) | Setup & Overview | Getting started |
| [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) | API Reference | API integration |
| [USAGE_GUIDE.md](./USAGE_GUIDE.md) | Practical Examples | Daily usage |
| [JAVASCRIPT_DOCUMENTATION.md](./JAVASCRIPT_DOCUMENTATION.md) | Frontend Guide | JavaScript development |

**Start here**: [README.md](./README.md) → [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) → [USAGE_GUIDE.md](./USAGE_GUIDE.md) → [JAVASCRIPT_DOCUMENTATION.md](./JAVASCRIPT_DOCUMENTATION.md)

---

*Last updated: 2025-09-30*