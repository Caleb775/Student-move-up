# Student Records App - Production Deployment Guide

## Overview

This guide provides comprehensive instructions for deploying the Student Records Application to production environments. The application supports multiple deployment methods including traditional server deployment, Docker containers, and cloud platforms.

## Prerequisites

### System Requirements
- **Ruby**: 3.3.6 (matches .ruby-version)
- **PostgreSQL**: 12+ (recommended 14+)
- **Node.js**: 18+ (for asset compilation)
- **Memory**: Minimum 2GB RAM, 4GB recommended
- **Storage**: Minimum 10GB free space
- **CPU**: 2+ cores recommended

### Required Software
- Git
- Bundler
- PostgreSQL client libraries
- ImageMagick or libvips (for image processing)

## Deployment Methods

### 1. Traditional Server Deployment

#### Step 1: Server Setup
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl git build-essential libpq-dev postgresql postgresql-contrib

# Install Ruby (using rbenv)
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install Ruby 3.3.6
rbenv install 3.3.6
rbenv global 3.3.6
```

#### Step 2: Application Setup
```bash
# Clone the repository
git clone https://github.com/your-username/student_records_app.git
cd student_records_app

# Install dependencies
bundle install --deployment --without development test

# Set up environment variables
cp config/deployment/env.production.example .env.production
# Edit .env.production with your actual values
```

#### Step 3: Database Setup
```bash
# Create production database
sudo -u postgres createdb student_records_app_production

# Run migrations
RAILS_ENV=production bundle exec rails db:migrate

# Seed database (optional)
RAILS_ENV=production bundle exec rails db:seed
```

#### Step 4: Asset Precompilation
```bash
# Precompile assets
RAILS_ENV=production bundle exec rails assets:precompile
```

#### Step 5: Deploy
```bash
# Run the deployment script
./bin/deploy
```

### 2. Docker Deployment

#### Step 1: Build Docker Image
```bash
# Build the production image
docker build -t student_records_app .

# Tag for registry (optional)
docker tag student_records_app your-registry/student_records_app:latest
```

#### Step 2: Run Container
```bash
# Run with environment variables
docker run -d \
  --name student_records_app \
  -p 80:80 \
  -e RAILS_MASTER_KEY=your_master_key \
  -e DATABASE_URL=postgresql://user:pass@host:5432/db \
  -e RAILS_HOST=your-domain.com \
  student_records_app
```

#### Step 3: Docker Compose (Recommended)
Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "80:80"
    environment:
      - RAILS_ENV=production
      - RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
      - DATABASE_URL=postgresql://postgres:password@db:5432/student_records_app_production
      - RAILS_HOST=${RAILS_HOST}
    depends_on:
      - db
    volumes:
      - ./storage:/rails/storage
      - ./log:/rails/log

  db:
    image: postgres:14
    environment:
      - POSTGRES_DB=student_records_app_production
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

Deploy:
```bash
docker-compose up -d
```

### 3. Cloud Platform Deployment

#### Heroku
```bash
# Install Heroku CLI
curl https://cli-assets.heroku.com/install.sh | sh

# Login to Heroku
heroku login

# Create Heroku app
heroku create your-app-name

# Set environment variables
heroku config:set RAILS_MASTER_KEY=your_master_key
heroku config:set RAILS_HOST=your-app-name.herokuapp.com

# Add PostgreSQL addon
heroku addons:create heroku-postgresql:mini

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate
```

#### DigitalOcean App Platform
1. Connect your GitHub repository
2. Configure build settings:
   - Build Command: `bundle install && rails assets:precompile`
   - Run Command: `bundle exec puma -C config/puma.rb`
3. Set environment variables
4. Deploy

#### AWS Elastic Beanstalk
```bash
# Install EB CLI
pip install awsebcli

# Initialize EB application
eb init

# Create environment
eb create production

# Deploy
eb deploy
```

## Environment Configuration

### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `RAILS_ENV` | Rails environment | `production` |
| `RAILS_MASTER_KEY` | Rails master key | `your_master_key_here` |
| `RAILS_HOST` | Application hostname | `your-domain.com` |
| `DATABASE_URL` | Database connection string | `postgresql://user:pass@host:5432/db` |
| `SECRET_KEY_BASE` | Secret key for sessions | `your_secret_key_base` |

### Optional Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `RAILS_MAX_THREADS` | Maximum threads | `5` |
| `WEB_CONCURRENCY` | Worker processes | `2` |
| `RAILS_LOG_LEVEL` | Log level | `info` |
| `SMTP_HOST` | SMTP server | - |
| `SMTP_PORT` | SMTP port | `587` |
| `SMTP_USERNAME` | SMTP username | - |
| `SMTP_PASSWORD` | SMTP password | - |

## Security Configuration

### SSL/TLS Setup
```bash
# Generate SSL certificate (using Let's Encrypt)
sudo apt install certbot
sudo certbot certonly --standalone -d your-domain.com

# Configure Nginx with SSL
sudo nano /etc/nginx/sites-available/student_records_app
```

Nginx configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Firewall Configuration
```bash
# Configure UFW firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## Monitoring and Maintenance

### Health Checks
```bash
# Check application health
curl -f http://localhost:3000/up

# Check database connection
RAILS_ENV=production bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1')"
```

### Log Monitoring
```bash
# View application logs
tail -f log/production.log

# View Puma logs
tail -f log/puma.stdout.log
tail -f log/puma.stderr.log

# View system logs
sudo journalctl -u student-records-app -f
```

### Performance Monitoring
```bash
# Check memory usage
free -h

# Check disk usage
df -h

# Check process status
ps aux | grep puma
```

### Backup Strategy
```bash
# Database backup
pg_dump student_records_app_production > backup_$(date +%Y%m%d_%H%M%S).sql

# Automated backup script
#!/bin/bash
BACKUP_DIR="/var/backups/student_records_app"
mkdir -p $BACKUP_DIR
pg_dump student_records_app_production > $BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete
```

## Troubleshooting

### Common Issues

#### 1. Database Connection Errors
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check database exists
sudo -u postgres psql -l | grep student_records_app

# Test connection
RAILS_ENV=production bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1')"
```

#### 2. Asset Compilation Errors
```bash
# Clear asset cache
RAILS_ENV=production bundle exec rails assets:clobber

# Recompile assets
RAILS_ENV=production bundle exec rails assets:precompile
```

#### 3. Permission Issues
```bash
# Fix file permissions
sudo chown -R deploy:deploy /var/www/student_records_app
sudo chmod -R 755 /var/www/student_records_app
```

#### 4. Memory Issues
```bash
# Check memory usage
free -h

# Restart application
sudo systemctl restart student-records-app

# Increase swap if needed
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Performance Optimization

#### 1. Database Optimization
```sql
-- Add indexes for better performance
CREATE INDEX CONCURRENTLY idx_students_user_id ON students(user_id);
CREATE INDEX CONCURRENTLY idx_notes_student_id ON notes(student_id);
CREATE INDEX CONCURRENTLY idx_notes_user_id ON notes(user_id);
```

#### 2. Caching
```ruby
# Enable Redis caching in production.rb
config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
```

#### 3. CDN Setup
```ruby
# Configure asset host in production.rb
config.asset_host = "https://cdn.your-domain.com"
```

## Scaling Considerations

### Horizontal Scaling
- Use load balancer (Nginx, HAProxy)
- Multiple application servers
- Shared database and Redis
- Session storage in Redis

### Vertical Scaling
- Increase server resources
- Optimize database queries
- Enable caching
- Use background job processing

## Maintenance Tasks

### Regular Maintenance
```bash
# Update dependencies
bundle update

# Run database maintenance
RAILS_ENV=production bundle exec rails db:migrate

# Clear old logs
find log/ -name "*.log" -mtime +30 -delete

# Clean up temporary files
RAILS_ENV=production bundle exec rails tmp:clear
```

### Security Updates
```bash
# Update system packages
sudo apt update && sudo apt upgrade

# Update Ruby gems
bundle update

# Check for security vulnerabilities
bundle audit
```

## Support and Documentation

### Additional Resources
- [Rails Deployment Guide](https://guides.rubyonrails.org/deployment.html)
- [Puma Configuration](https://github.com/puma/puma/blob/master/docs/deployment.md)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### Getting Help
- Check application logs for errors
- Review system logs for issues
- Monitor resource usage
- Test database connectivity
- Verify environment variables

This deployment guide provides a comprehensive foundation for deploying the Student Records Application to production. Choose the deployment method that best fits your infrastructure and requirements.
