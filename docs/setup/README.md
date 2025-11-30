# Setup & Installation Documentation

Complete setup guides for development, testing, and production deployment.

## 🚀 Setup Overview

This section covers:
- **Local development** setup
- **Environment configuration**
- **Dependencies** installation
- **Database** setup and migrations
- **Production deployment**

## 📁 Files in this section

### [`SETUP_GUIDE.md`](SETUP_GUIDE.md)
Comprehensive installation guide:
- **Prerequisites** - Required software and versions
- **Local setup** - Step-by-step development environment
- **Environment variables** - Configuration options
- **Database setup** - PostgreSQL and Redis configuration  
- **Testing setup** - Running the test suite
- **Production deployment** - VPS and cloud platform deployment
- **Troubleshooting** - Common setup issues

## 🛠️ Quick Start

### **Prerequisites**
- **Ruby**: 3.3.x
- **Rails**: 7.0.x
- **PostgreSQL**: 12+
- **Redis**: 6+
- **Node.js**: 16+ (for dependencies)

### **1. Clone & Install**
```bash
git clone https://github.com/kane-nguyen-1217/daily_ai_agent_api.git
cd daily_ai_agent_api
bundle install
```

### **2. Environment Setup**
```bash
cp .env.example .env
# Edit .env with your configuration
```

### **3. Database Setup**
```bash
rails db:create
rails db:migrate
rails db:seed
```

### **4. Start Services**
```bash
# Terminal 1 - API Server
rails server

# Terminal 2 - Background Jobs
bundle exec sidekiq

# Terminal 3 - Redis (if not running as service)
redis-server
```

## 🔧 Environment Configuration

### **Required Variables**
```bash
# Database
DB_HOST=localhost
DB_USERNAME=postgres
DB_PASSWORD=your_password

# JWT Authentication
JWT_SECRET_KEY=your_jwt_secret_key

# Encryption
LOCKBOX_MASTER_KEY=your_lockbox_master_key

# Redis
REDIS_URL=redis://localhost:6379/0
```

### **Calendar Integration** (Optional)
```bash
# Google Calendar
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Microsoft Calendar
MICROSOFT_CLIENT_ID=your_microsoft_client_id
MICROSOFT_CLIENT_SECRET=your_microsoft_client_secret

# Frontend URL for OAuth redirects
FRONTEND_URL=http://localhost:3001
```

### **External Services** (Optional)
```bash
# Telegram Bot
TELEGRAM_BOT_TOKEN=your_bot_token

# n8n Integration
N8N_URL=http://localhost:5678
N8N_API_KEY=your_n8n_api_key

# AI Services
OPENAI_API_KEY=your_openai_key

# Cryptocurrency Data
CRYPTO_API_KEY=your_crypto_api_key
```

## 🗄️ Database Setup

### **PostgreSQL Installation**

#### macOS
```bash
# Using Homebrew
brew install postgresql
brew services start postgresql

# Create user
createuser -s postgres
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### Windows
Download and install from: https://www.postgresql.org/download/windows/

### **Database Configuration**
```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Seed initial data
rails db:seed

# Reset database (if needed)
rails db:drop db:create db:migrate db:seed
```

## 🔴 Redis Setup

### **Installation**

#### macOS
```bash
brew install redis
brew services start redis
```

#### Ubuntu/Debian  
```bash
sudo apt update
sudo apt install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

#### Windows
Download from: https://redis.io/download

### **Verification**
```bash
redis-cli ping
# Should return: PONG
```

## 🧪 Testing Setup

### **Run Test Suite**
```bash
# Install test dependencies
bundle install

# Setup test database
RAILS_ENV=test rails db:create db:migrate

# Run all tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec

# Run specific tests
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/api/v1/
```

### **Test Database**
```bash
# Reset test database
RAILS_ENV=test rails db:reset

# Check test configuration
rails runner -e test "puts Rails.env"
```

## 🐳 Docker Setup

### **Development with Docker**
```bash
# Build and start services
docker-compose up -d

# Run migrations
docker-compose exec web rails db:migrate

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### **Docker Configuration**
The project includes:
- `Dockerfile` - Rails app container
- `docker-compose.yml` - Multi-service setup
- Services: Rails app, PostgreSQL, Redis

## 🚀 Production Deployment

### **Environment Setup**
```bash
# Production environment variables
RAILS_ENV=production
RAILS_MASTER_KEY=your_master_key
SECRET_KEY_BASE=your_secret_key_base

# Database
DATABASE_URL=postgresql://user:pass@host:port/database

# External URLs
FRONTEND_URL=https://yourdomain.com
```

### **Deployment Steps**
```bash
# Install production dependencies
bundle install --without development test

# Precompile assets (if needed)
RAILS_ENV=production rails assets:precompile

# Run migrations
RAILS_ENV=production rails db:migrate

# Start services
RAILS_ENV=production rails server -p 3000
RAILS_ENV=production bundle exec sidekiq
```

### **Process Management**
Consider using:
- **systemd** for service management
- **nginx** as reverse proxy
- **PM2** for Node.js process management
- **Docker** for containerized deployment

## 🔧 Development Tools

### **Useful Commands**
```bash
# Rails console
rails console

# Database console  
rails dbconsole

# Routes
rails routes

# Generate migration
rails generate migration AddFieldToModel field:type

# Annotate models with schema
bundle exec annotate
```

### **Code Quality**
```bash
# Ruby style checking
bundle exec rubocop

# Auto-fix style issues
bundle exec rubocop -a

# Security scanning
bundle exec brakeman
```

## 🔍 Troubleshooting

### **Common Issues**

#### Database Connection Error
```bash
# Check PostgreSQL is running
brew services list | grep postgresql

# Check database exists
psql -l | grep daily_ai_agent

# Reset database permissions
createuser -s postgres
```

#### Redis Connection Error  
```bash
# Check Redis is running
redis-cli ping

# Start Redis service
brew services start redis
```

#### Gem Installation Issues
```bash
# Update bundler
gem update bundler

# Clean bundle
bundle clean --force
bundle install
```

#### Migration Issues
```bash
# Check migration status
rails db:migrate:status

# Rollback last migration
rails db:rollback

# Reset database
rails db:drop db:create db:migrate db:seed
```

### **Port Conflicts**
```bash
# Check what's using port 3000
lsof -i :3000

# Kill process on port 3000
kill -9 $(lsof -t -i:3000)

# Use different port
rails server -p 3001
```

## 🔗 Related Documentation

- **[Development Guide](../development/)** - Contributing and coding standards
- **[Database Schema](../database/)** - Database structure and relationships
- **[API Documentation](../api/)** - API endpoints and testing
- **[Calendar Integration](../calendar-integration/)** - Calendar feature setup

## 📞 Support

### **Getting Help**
- Check the troubleshooting section above
- Review related documentation sections  
- Search existing GitHub issues
- Create new issue with setup details

### **Development Environment**
- **Ruby version**: Check with `ruby -v`
- **Rails version**: Check with `rails -v`
- **Database**: Verify with `rails dbconsole`
- **Redis**: Verify with `redis-cli ping`

For complete setup instructions, see [`SETUP_GUIDE.md`](SETUP_GUIDE.md).
