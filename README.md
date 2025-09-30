# Student Language Proficiency Tracker

A Ruby on Rails application for managing student language proficiency scores and notes. Track student performance across four language skills: reading, writing, listening, and speaking.

## Table of Contents

- [Features](#features)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [Usage Guide](#usage-guide)
- [Testing](#testing)
- [Deployment](#deployment)
- [API Documentation](#api-documentation)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Student Management**: Create, read, update, and delete student records
- **Score Tracking**: Track scores across four language skills (0-10 scale)
- **Automatic Calculations**: Total scores and percentages calculated automatically
- **Note Taking**: Add, edit, and delete notes for each student
- **Sorting**: Students automatically sorted by performance (highest to lowest)
- **Responsive Design**: Modern UI with Hotwire (Turbo + Stimulus)
- **Real-time Updates**: Turbo-powered page updates without full page reloads

---

## Technology Stack

- **Framework**: Ruby on Rails 8.0.3
- **Language**: Ruby 3.x
- **Database**: PostgreSQL
- **Frontend**: 
  - Hotwire (Turbo Rails + Stimulus)
  - Importmap for JavaScript modules
  - Propshaft for asset pipeline
- **Web Server**: Puma
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **Action Cable**: Solid Cable
- **Deployment**: Kamal (Docker-based deployment)

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby** 3.0 or higher
  ```bash
  ruby --version
  ```

- **Rails** 8.0.3
  ```bash
  gem install rails -v 8.0.3
  ```

- **PostgreSQL** 12 or higher
  ```bash
  psql --version
  ```

- **Node.js** (for JavaScript dependencies)
  ```bash
  node --version
  ```

- **Bundler**
  ```bash
  gem install bundler
  ```

---

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <project-directory>
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies (if needed)
# Not required for this project as we use importmap
```

### 3. Set up Environment Variables

Create a `.env` file in the root directory (optional, for production):

```bash
DATABASE_URL=postgresql://username:password@localhost/dbname
RAILS_MASTER_KEY=<your-master-key>
```

---

## Configuration

### Database Configuration

Edit `config/database.yml` to match your PostgreSQL setup:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: student_tracker_development

test:
  <<: *default
  database: student_tracker_test

production:
  <<: *default
  database: student_tracker_production
  username: <%= ENV['DATABASE_USERNAME'] %>
  password: <%= ENV['DATABASE_PASSWORD'] %>
```

---

## Database Setup

### Create and Migrate Database

```bash
# Create the database
rails db:create

# Run migrations
rails db:migrate

# (Optional) Seed the database with sample data
rails db:seed
```

### Database Migrations

The application includes the following tables:

**Students Table**:
- `name` (string): Student's name
- `reading` (integer): Reading score (0-10)
- `writing` (integer): Writing score (0-10)
- `listening` (integer): Listening score (0-10)
- `speaking` (integer): Speaking score (0-10)
- `total_score` (integer): Sum of all scores
- `percentage` (float): Percentage score
- Timestamps: `created_at`, `updated_at`

**Notes Table**:
- `content` (text): Note content
- `student_id` (bigint): Foreign key to students
- Timestamps: `created_at`, `updated_at`

---

## Running the Application

### Development Server

```bash
# Start the Rails server
rails server

# Or use the short form
rails s
```

The application will be available at `http://localhost:3000`

### Development with Bin Dev

The project includes a development script that may start additional services:

```bash
bin/dev
```

### Production Server

```bash
# Precompile assets
rails assets:precompile

# Run in production mode
RAILS_ENV=production rails server
```

---

## Usage Guide

### Creating a Student

1. Navigate to `http://localhost:3000`
2. Click "New Student"
3. Fill in the form:
   - **Name**: Student's full name
   - **Reading**: Score from 0 to 10
   - **Writing**: Score from 0 to 10
   - **Listening**: Score from 0 to 10
   - **Speaking**: Score from 0 to 10
4. Click "Create Student"

The total score and percentage will be calculated automatically.

**Example**:
```
Name: John Doe
Reading: 8
Writing: 7
Listening: 9
Speaking: 8

Result:
Total Score: 32 / 40
Percentage: 80.0%
```

### Viewing Students

- **All Students**: Visit the home page to see all students sorted by percentage (highest first)
- **Individual Student**: Click on a student's name to view their details

### Editing a Student

1. Go to a student's detail page
2. Click "Edit Student"
3. Modify the scores as needed
4. Click "Update Student"

Scores are recalculated automatically.

### Deleting a Student

1. Go to a student's detail page
2. Click "Delete Student"
3. Confirm the deletion

**Warning**: Deleting a student will also delete all associated notes.

### Managing Notes

#### Adding a Note

1. Go to a student's detail page
2. Click "Add Note"
3. Enter note content (1-1000 characters)
4. Click "Create Note"

#### Editing a Note

1. Go to a student's detail page
2. Find the note you want to edit
3. Click "Edit"
4. Modify the content
5. Click "Update Note"

#### Deleting a Note

1. Go to a student's detail page
2. Find the note you want to delete
3. Click "Delete"
4. Confirm the deletion

### Code Examples

#### Using Rails Console

```bash
# Start the Rails console
rails console
```

**Create a student**:
```ruby
student = Student.create(
  name: "Alice Johnson",
  reading: 9,
  writing: 8,
  listening: 9,
  speaking: 10
)

puts "Total: #{student.total_score} / 40"
puts "Percentage: #{student.percentage}%"
```

**Add a note**:
```ruby
student = Student.find(1)
student.notes.create(content: "Excellent progress in speaking skills")
```

**Find top students**:
```ruby
top_students = Student.order(percentage: :desc).limit(5)
top_students.each do |student|
  puts "#{student.name}: #{student.percentage}%"
end
```

**Get students with high scores**:
```ruby
high_performers = Student.where('percentage >= ?', 80)
```

---

## Testing

### Run All Tests

```bash
# Run all unit and integration tests
rails test

# Run with verbose output
rails test -v
```

### Run Specific Tests

```bash
# Test a specific file
rails test test/models/student_test.rb

# Test a specific test case
rails test test/models/student_test.rb:10
```

### Run System Tests

```bash
# Run system tests (requires Chrome/Firefox)
rails test:system
```

### Code Quality

```bash
# Run Rubocop (code style checker)
bin/rubocop

# Run Brakeman (security scanner)
bin/brakeman
```

---

## Deployment

### Docker Deployment with Kamal

The application includes Kamal configuration for Docker-based deployment.

```bash
# Setup Kamal
kamal setup

# Deploy the application
kamal deploy

# View deployment status
kamal app details
```

### Traditional Deployment

1. **Prepare the server**:
   - Install Ruby, PostgreSQL, and Nginx
   - Set up the database

2. **Deploy the code**:
   ```bash
   git clone <repository-url>
   cd <project-directory>
   bundle install --without development test
   ```

3. **Configure environment**:
   ```bash
   RAILS_ENV=production rails assets:precompile
   RAILS_ENV=production rails db:migrate
   ```

4. **Start the server**:
   ```bash
   RAILS_ENV=production rails server -p 3000
   ```

### Environment Variables for Production

```bash
RAILS_ENV=production
DATABASE_URL=postgresql://user:password@localhost/dbname
RAILS_MASTER_KEY=<from config/master.key>
SECRET_KEY_BASE=<generate with: rails secret>
```

---

## API Documentation

For detailed API documentation, including all endpoints, request/response formats, and code examples, see:

**[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)**

### Quick API Reference

#### Student Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/students` | List all students |
| POST | `/students` | Create a student |
| GET | `/students/:id` | Show a student |
| PATCH | `/students/:id` | Update a student |
| DELETE | `/students/:id` | Delete a student |

#### Note Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/students/:student_id/notes` | List notes |
| POST | `/students/:student_id/notes` | Create a note |
| GET | `/students/:student_id/notes/:id` | Show a note |
| PATCH | `/students/:student_id/notes/:id` | Update a note |
| DELETE | `/students/:student_id/notes/:id` | Delete a note |

---

## Project Structure

```
.
├── app/
│   ├── controllers/       # Request handlers
│   │   ├── students_controller.rb
│   │   └── notes_controller.rb
│   ├── models/           # Data models
│   │   ├── student.rb
│   │   └── note.rb
│   ├── views/            # HTML templates
│   │   ├── students/
│   │   └── notes/
│   ├── javascript/       # Stimulus controllers
│   │   └── controllers/
│   └── helpers/          # View helpers
├── config/
│   ├── routes.rb         # URL routing
│   ├── database.yml      # Database configuration
│   └── environments/     # Environment configs
├── db/
│   ├── migrate/          # Database migrations
│   └── schema.rb         # Database schema
├── test/                 # Test files
│   ├── models/
│   ├── controllers/
│   └── system/
├── Gemfile               # Ruby dependencies
└── README.md             # This file
```

---

## Common Tasks

### Resetting the Database

```bash
# Drop, create, and migrate
rails db:reset

# Or step by step
rails db:drop
rails db:create
rails db:migrate
rails db:seed
```

### Viewing Routes

```bash
# List all routes
rails routes

# Search for specific routes
rails routes | grep student
```

### Console Commands

```bash
# Start Rails console
rails console

# Or in production
RAILS_ENV=production rails console
```

### Logs

```bash
# View development logs
tail -f log/development.log

# View production logs
tail -f log/production.log
```

---

## Troubleshooting

### Database Connection Issues

**Problem**: Can't connect to PostgreSQL

**Solution**:
```bash
# Check if PostgreSQL is running
sudo service postgresql status

# Start PostgreSQL
sudo service postgresql start

# Verify database exists
rails db:create
```

### Asset Issues

**Problem**: Assets not loading

**Solution**:
```bash
# Clear asset cache
rails tmp:clear

# In production, precompile assets
RAILS_ENV=production rails assets:precompile
```

### Port Already in Use

**Problem**: Port 3000 is already in use

**Solution**:
```bash
# Use a different port
rails server -p 3001

# Or kill the process using port 3000
lsof -ti:3000 | xargs kill -9
```

---

## Performance Tips

1. **Database Indexing**: The application includes indexes on foreign keys
2. **Query Optimization**: Use `includes` to avoid N+1 queries:
   ```ruby
   students = Student.includes(:notes).all
   ```
3. **Caching**: Solid Cache is configured for production
4. **Background Jobs**: Use Solid Queue for heavy operations

---

## Security

- **Strong Parameters**: All controllers use strong parameters
- **CSRF Protection**: Enabled by default
- **SQL Injection Prevention**: Use parameterized queries
- **Validation**: All models have proper validations
- **Brakeman**: Run security scans regularly

```bash
bin/brakeman
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

This project follows the Rails Omakase Rubocop style guide:

```bash
# Check code style
bin/rubocop

# Auto-fix issues
bin/rubocop -a
```

---

## Support

- **Documentation**: See [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
- **Issues**: Report bugs via GitHub issues
- **Health Check**: Visit `/up` to verify the application is running

---

## License

This project is available for use under the applicable license terms.

---

## Acknowledgments

- Built with Ruby on Rails 8.0.3
- Uses Hotwire for modern frontend interactions
- PostgreSQL for reliable data storage
- Solid Queue, Cache, and Cable for production readiness

---

## Version History

### Current Version

- Rails 8.0.3
- Ruby 3.x
- PostgreSQL support
- Hotwire integration
- Solid adapters for production

---

For detailed API documentation and code examples, please refer to [API_DOCUMENTATION.md](./API_DOCUMENTATION.md).