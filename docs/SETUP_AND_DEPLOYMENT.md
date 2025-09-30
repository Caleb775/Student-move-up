# Setup and Deployment Guide

## Overview

This guide provides comprehensive instructions for setting up, configuring, and deploying the Student Management System. The application is built with Ruby on Rails 8.0 and uses modern web technologies.

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Local Development Setup](#local-development-setup)
3. [Database Configuration](#database-configuration)
4. [Environment Configuration](#environment-configuration)
5. [Running the Application](#running-the-application)
6. [Testing](#testing)
7. [Production Deployment](#production-deployment)
8. [Docker Deployment](#docker-deployment)
9. [Troubleshooting](#troubleshooting)

---

## System Requirements

### Minimum Requirements

- **Ruby**: 3.2.0 or higher
- **Rails**: 8.0.3
- **PostgreSQL**: 13.0 or higher
- **Node.js**: 18.0 or higher (for asset compilation)
- **Git**: 2.0 or higher

### Recommended System Specifications

- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 10GB free space
- **CPU**: 2+ cores recommended

### Supported Operating Systems

- **macOS**: 10.15 (Catalina) or higher
- **Linux**: Ubuntu 20.04+, CentOS 8+, or equivalent
- **Windows**: Windows 10/11 with WSL2

---

## Local Development Setup

### 1. Install System Dependencies

#### macOS (using Homebrew)

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install ruby postgresql node git
brew services start postgresql
```

#### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install dependencies
sudo apt install -y ruby-dev postgresql postgresql-contrib nodejs npm git build-essential libpq-dev

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### CentOS/RHEL/Fedora

```bash
# Install dependencies
sudo dnf install -y ruby ruby-devel postgresql postgresql-server postgresql-contrib nodejs npm git gcc make libpq-devel

# Initialize and start PostgreSQL
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 2. Clone the Repository

```bash
# Clone the repository
git clone <repository-url>
cd student-management-system

# Or if you're setting up from an existing directory
cd /path/to/your/project
```

### 3. Install Ruby Dependencies

```bash
# Install bundler if not already installed
gem install bundler

# Install project dependencies
bundle install
```

### 4. Install JavaScript Dependencies

```bash
# Install Node.js dependencies (if any)
npm install

# Or if using Yarn
yarn install
```

---

## Database Configuration

### 1. PostgreSQL Setup

#### Create Database User

```bash
# Switch to postgres user
sudo -u postgres psql

# In PostgreSQL console, create user and database
CREATE USER student_app_user WITH PASSWORD 'your_secure_password';
CREATE DATABASE student_management_development OWNER student_app_user;
CREATE DATABASE student_management_test OWNER student_app_user;
ALTER USER student_app_user CREATEDB;

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE student_management_development TO student_app_user;
GRANT ALL PRIVILEGES ON DATABASE student_management_test TO student_app_user;

# Exit PostgreSQL console
\q
```

### 2. Database Configuration File

Update `config/database.yml` if needed:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: student_management_development
  username: student_app_user
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: localhost
  port: 5432

test:
  <<: *default
  database: student_management_test
  username: student_app_user
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: localhost
  port: 5432

production:
  <<: *default
  database: student_management_production
  username: <%= ENV['DATABASE_USERNAME'] %>
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: <%= ENV['DATABASE_HOST'] %>
  port: <%= ENV['DATABASE_PORT'] %>
```

### 3. Database Setup

```bash
# Create and setup databases
rails db:create
rails db:migrate
rails db:seed

# For test database
RAILS_ENV=test rails db:create
RAILS_ENV=test rails db:migrate
```

---

## Environment Configuration

### 1. Environment Variables

Create a `.env` file in the project root:

```bash
# Database Configuration
DATABASE_PASSWORD=your_secure_password
DATABASE_USERNAME=student_app_user
DATABASE_HOST=localhost
DATABASE_PORT=5432

# Rails Configuration
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key_base_here

# Application Configuration
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2

# Optional: External Services
# REDIS_URL=redis://localhost:6379/0
# ELASTICSEARCH_URL=http://localhost:9200
```

### 2. Generate Secret Key Base

```bash
# Generate a new secret key base
rails secret

# Add it to your .env file or Rails credentials
```

### 3. Rails Credentials (Alternative to .env)

```bash
# Edit encrypted credentials
EDITOR=nano rails credentials:edit

# Add your secrets:
# database:
#   password: your_secure_password
# secret_key_base: your_generated_secret_key
```

---

## Running the Application

### 1. Development Server

```bash
# Start the Rails server
rails server

# Or with specific port
rails server -p 3000

# Or using the dev script
bin/dev
```

The application will be available at `http://localhost:3000`

### 2. Background Jobs (if applicable)

```bash
# Start Solid Queue (for background jobs)
rails solid_queue:start

# Or in separate terminal
bundle exec rails runner "SolidQueue::Worker.new.start"
```

### 3. Asset Compilation

```bash
# Precompile assets for production-like testing
rails assets:precompile

# Clean compiled assets
rails assets:clobber
```

### 4. Console Access

```bash
# Rails console
rails console

# Or shorter version
rails c

# Production console (be careful!)
RAILS_ENV=production rails console
```

---

## Testing

### 1. Running Tests

```bash
# Run all tests
rails test

# Run specific test files
rails test test/models/student_test.rb
rails test test/controllers/students_controller_test.rb

# Run system tests
rails test:system

# Run tests with coverage (if configured)
COVERAGE=true rails test
```

### 2. Test Database Management

```bash
# Reset test database
RAILS_ENV=test rails db:reset

# Migrate test database
RAILS_ENV=test rails db:migrate
```

### 3. Linting and Code Quality

```bash
# Run RuboCop (Ruby linting)
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -a

# Run Brakeman (security analysis)
bundle exec brakeman

# Run all quality checks
bin/rubocop && bin/brakeman
```

---

## Production Deployment

### 1. Server Requirements

#### Minimum Production Specifications

- **RAM**: 2GB minimum, 4GB+ recommended
- **CPU**: 2+ cores
- **Storage**: 20GB+ SSD recommended
- **Network**: Stable internet connection

#### Software Requirements

- **Ruby**: 3.2.0+
- **PostgreSQL**: 13.0+
- **Nginx**: 1.18+ (recommended reverse proxy)
- **Redis**: 6.0+ (for caching and background jobs)

### 2. Traditional Server Deployment

#### Prepare the Server

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y ruby-dev postgresql postgresql-contrib nginx redis-server nodejs npm git build-essential libpq-dev

# Install rbenv for Ruby version management
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install Ruby
rbenv install 3.2.0
rbenv global 3.2.0
```

#### Deploy Application

```bash
# Clone repository
git clone <repository-url> /var/www/student-management-system
cd /var/www/student-management-system

# Install dependencies
bundle install --deployment --without development test
npm install --production

# Set up environment
sudo cp .env.example .env
sudo nano .env  # Configure production values

# Database setup
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails db:seed

# Precompile assets
RAILS_ENV=production rails assets:precompile

# Set permissions
sudo chown -R www-data:www-data /var/www/student-management-system
```

#### Configure Nginx

Create `/etc/nginx/sites-available/student-management-system`:

```nginx
upstream student_app {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    root /var/www/student-management-system/public;
    
    location / {
        try_files $uri @app;
    }
    
    location @app {
        proxy_pass http://student_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/student-management-system /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### Create Systemd Service

Create `/etc/systemd/system/student-management-system.service`:

```ini
[Unit]
Description=Student Management System Rails App
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/student-management-system
ExecStart=/home/www-data/.rbenv/shims/bundle exec rails server -e production -p 3000
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=student-app
Environment=RAILS_ENV=production

[Install]
WantedBy=multi-user.target
```

Start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable student-management-system
sudo systemctl start student-management-system
```

### 3. SSL/HTTPS Setup

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Test automatic renewal
sudo certbot renew --dry-run
```

---

## Docker Deployment

### 1. Using the Provided Dockerfile

The application includes a `Dockerfile` for containerized deployment.

#### Build and Run Locally

```bash
# Build the Docker image
docker build -t student-management-system .

# Run with Docker Compose (recommended)
docker-compose up -d

# Or run manually
docker run -d \
  --name student-app \
  -p 3000:3000 \
  -e DATABASE_URL=postgresql://user:password@db:5432/student_management_production \
  student-management-system
```

#### Docker Compose Configuration

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: student_management_production
      POSTGRES_USER: student_app_user
      POSTGRES_PASSWORD: secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgresql://student_app_user:secure_password@db:5432/student_management_production
      REDIS_URL: redis://redis:6379/0
      RAILS_ENV: production
      SECRET_KEY_BASE: your_secret_key_base_here
    depends_on:
      - db
      - redis
    volumes:
      - ./storage:/rails/storage

volumes:
  postgres_data:
```

### 2. Kamal Deployment

The application is configured for Kamal deployment (included in Gemfile).

#### Configure Kamal

Edit `config/deploy.yml`:

```yaml
service: student-management-system
image: student-app

servers:
  web:
    - your-server-ip

registry:
  server: your-registry.com
  username: your-username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  clear:
    DATABASE_HOST: your-db-host
    REDIS_URL: redis://your-redis-host:6379/0
  secret:
    - DATABASE_PASSWORD
    - SECRET_KEY_BASE

volumes:
  - "/var/lib/student-app/storage:/rails/storage"

healthcheck:
  path: /up
  port: 3000
  max_attempts: 7
  interval: 20s
```

#### Deploy with Kamal

```bash
# Setup Kamal
kamal setup

# Deploy application
kamal deploy

# Check status
kamal app logs
kamal app details
```

---

## Monitoring and Maintenance

### 1. Log Management

```bash
# View Rails logs
tail -f log/production.log

# View system logs
sudo journalctl -u student-management-system -f

# Rotate logs
sudo logrotate -f /etc/logrotate.d/student-management-system
```

### 2. Database Maintenance

```bash
# Database backup
pg_dump -h localhost -U student_app_user student_management_production > backup_$(date +%Y%m%d_%H%M%S).sql

# Database restore
psql -h localhost -U student_app_user student_management_production < backup_file.sql

# Analyze database performance
RAILS_ENV=production rails db:analyze
```

### 3. Performance Monitoring

```bash
# Check application performance
curl -I http://your-domain.com/up

# Monitor system resources
htop
df -h
free -m

# Check database connections
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity WHERE datname = 'student_management_production';"
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Database Connection Issues

**Problem**: `PG::ConnectionBad: could not connect to server`

**Solutions**:
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Restart PostgreSQL
sudo systemctl restart postgresql

# Check database configuration
rails db:migrate:status

# Verify credentials
psql -h localhost -U student_app_user -d student_management_development
```

#### 2. Asset Compilation Errors

**Problem**: Assets not loading or compilation failures

**Solutions**:
```bash
# Clear asset cache
rails assets:clobber

# Recompile assets
RAILS_ENV=production rails assets:precompile

# Check Node.js version
node --version
npm --version

# Reinstall Node modules
rm -rf node_modules
npm install
```

#### 3. Permission Issues

**Problem**: File permission errors

**Solutions**:
```bash
# Fix ownership
sudo chown -R www-data:www-data /var/www/student-management-system

# Fix permissions
sudo chmod -R 755 /var/www/student-management-system
sudo chmod -R 644 /var/www/student-management-system/config/*
```

#### 4. Memory Issues

**Problem**: Application running out of memory

**Solutions**:
```bash
# Check memory usage
free -m
ps aux --sort=-%mem | head

# Adjust Puma configuration
# Edit config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY") { 1 }  # Reduce workers
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 3 }  # Reduce threads
```

#### 5. SSL Certificate Issues

**Problem**: HTTPS not working or certificate errors

**Solutions**:
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew

# Test Nginx configuration
sudo nginx -t

# Check certificate expiration
openssl x509 -in /etc/letsencrypt/live/your-domain.com/cert.pem -text -noout | grep "Not After"
```

### Getting Help

1. **Check Logs**: Always start by checking application and system logs
2. **Rails Console**: Use `rails console` to debug data and model issues
3. **Database Console**: Use `rails db` to check database directly
4. **Community Resources**:
   - Rails Guides: https://guides.rubyonrails.org/
   - Stack Overflow: Tag questions with `ruby-on-rails`
   - Rails Community Forum: https://discuss.rubyonrails.org/

### Health Checks

The application includes a health check endpoint at `/up` that verifies:
- Database connectivity
- Redis connectivity (if configured)
- Application responsiveness

Use this endpoint for monitoring and load balancer health checks.

---

## Security Considerations

### 1. Environment Variables

- Never commit `.env` files to version control
- Use Rails credentials for sensitive data in production
- Rotate secrets regularly

### 2. Database Security

- Use strong passwords for database users
- Limit database user privileges
- Enable SSL for database connections in production
- Regular security updates

### 3. Application Security

- Keep Rails and gems updated
- Run `bundle audit` regularly for security vulnerabilities
- Use HTTPS in production
- Configure proper CORS if needed
- Enable security headers

### 4. Server Security

- Keep server OS updated
- Use firewall to limit open ports
- Implement fail2ban for SSH protection
- Regular security audits

This comprehensive setup guide should help you successfully deploy and maintain the Student Management System in various environments.