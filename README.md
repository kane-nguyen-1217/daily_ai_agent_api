# Daily AI Agent API

A comprehensive Ruby on Rails API ba## 📖 Documentation

All documentation is organized by feature in the [`docs/`](docs/) folder:

- **[📋 Documentation Index](docs/INDEX.md)** - Complete documentation overview
- **[️ Setup & Installation](docs/setup/)** - Installation, configuration, deployment
- **[📅 Calendar Integration](docs/calendar-integration/)** - Google/Microsoft calendar setup
- **[🗄️ Database Schema](docs/database/)** - Complete database documentation  
- **[📡 API Reference](docs/api/)** - Endpoints, Swagger, testing tools
- **[🔐 OAuth Integration](docs/oauth-integration/)** - Google/Microsoft OAuth setup
- **[🛠️ Development](docs/development/)** - Contributing, architecture, standards Personal AI Agent platform with calendar integration, automation, and multi-service connectivity.

## 🚀 Quick Start

### Prerequisites
- Ruby 3.2+
- PostgreSQL 14+
- Redis 6+
- Node.js 16+ (for asset compilation)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/kane-nguyen-1217/daily_ai_agent_api.git
cd daily_ai_agent_api

# 2. Install dependencies
bundle install

# 3. Configure environment
cp .env.example .env
# Edit .env with your API keys and configuration

# 4. Setup database
rails db:create db:migrate db:seed

# 5. Start services
rails server                 # API server (port 3000)
bundle exec sidekiq         # Background jobs (separate terminal)
```

**🎉 API is now running at http://localhost:3000!**

### Development Services
- **API Server**: http://localhost:3000
- **API Documentation**: http://localhost:3000/api-docs
- **Sidekiq Web UI**: http://localhost:4567 (if sidekiq-web gem is enabled)

## 📖 Documentation

All documentation is organized by feature in the [`docs/`](docs/) folder:

- **[📋 Documentation Index](docs/INDEX.md)** - Complete documentation overview
- **[🛠️ Setup & Installation](docs/setup/)** - Installation, configuration, deployment
- **[📅 Calendar Integration](docs/calendar-integration/)** - Google/Microsoft calendar setup
- **[🗄️ Database Schema](docs/database/)** - Complete database documentation  
- **[� API Reference](docs/api/)** - Endpoints, Swagger, testing tools
- **[🔐 OAuth Integration](docs/oauth-integration/)** - Google/Microsoft OAuth setup
- **[🛠️ Development](docs/development/)** - Contributing, architecture, standards

## ✨ Features

### **Calendar Integration**
- 📅 Google Calendar & Microsoft Outlook integration
- 🔄 Automatic daily digest delivery
- 🔐 Secure OAuth token management with encryption
- ⏰ Timezone-aware scheduling

### **Automation System**
- ⚡ User-defined automation settings
- 📝 Cron-based scheduled jobs
- 🔄 Background job processing with Sidekiq
- 📊 AI-powered summaries

### **Multi-Service Integration**
- 🤖 Telegram bot integration
- 💰 Cryptocurrency data tracking
- 🔗 n8n workflow integration
- 🚨 Alert and notification system

### **Security & Performance**
- 🔒 JWT-based authentication
- 🔐 Lockbox encryption for sensitive data
- 📊 PostgreSQL with optimized indexing
- 🚀 Redis-backed background jobs

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │────│   Rails API     │────│   PostgreSQL    │
│   (External)    │    │   (Port 3000)   │    │   Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              │
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Sidekiq       │────│   Redis         │
                       │   (Background)  │    │   (Job Queue)   │
                       └─────────────────┘    └─────────────────┘
                              │
                       ┌─────────────────┐
                       │   External APIs │
                       │   • Google Cal  │
                       │   • Microsoft   │
                       │   • Telegram    │
                       │   • Crypto APIs │
                       └─────────────────┘
```

## 🔗 API Endpoints

### **Authentication**
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Token refresh

### **Calendar Integration**
- `GET /api/v1/calendar/google/connect` - Google OAuth
- `GET /api/v1/calendar/microsoft/connect` - Microsoft OAuth
- `GET /api/v1/calendar/:provider/callback` - OAuth callback

### **Full API Documentation**
- **Swagger UI**: http://localhost:3000/api-docs
- **[Complete API Docs](docs/api/API_DOCUMENTATION.md)**
- **[Postman Collection](docs/api/api_collection.json)**

## 🧪 Testing

### **Calendar Integration Testing**
```bash
# Test calendar connection
rails calendar:test_digest[1,"2025-11-30"]

# Check calendar accounts
rails console
User.first.calendar_accounts.active
```

### **API Testing**
```bash
# Test authentication
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"password123"}'
```

More testing examples in [Calendar Quick Reference](docs/calendar-integration/CALENDAR_QUICK_REFERENCE.md)

## 🗄️ Database

**12 Tables** with comprehensive relationships:
- `users` (central hub)
- `calendar_accounts` (Google/Microsoft tokens)
- `notifications` (in-app notifications)
- `oauth_tokens`, `telegram_links`, `automation_settings`
- `scheduler_jobs`, `ai_summaries`, `alerts`
- `crypto_data_caches`, `n8n_webhook_logs`

See [Database Schema Documentation](docs/database/DATABASE_SCHEMA.md) for complete details.

## 🛠️ Tech Stack

- **Backend**: Ruby 3.3, Rails 7.0
- **Database**: PostgreSQL with JSONB
- **Background Jobs**: Sidekiq + Redis
- **Authentication**: JWT tokens
- **Encryption**: Lockbox for sensitive data
- **API Documentation**: Swagger/OpenAPI
- **Testing**: RSpec, Factory Bot

## 🔧 Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Start development
rails server
bundle exec sidekiq

# Check code quality
bundle exec rubocop
```

See [Contributing Guidelines](docs/development/CONTRIBUTING.md) for detailed development setup.

## 📦 Deployment

### **Production Server**
- Set `RAILS_ENV=production`
- Configure `RAILS_MASTER_KEY`
- Setup Redis and PostgreSQL
- Run migrations: `rails db:migrate`

See [Setup Guide](docs/setup/SETUP_GUIDE.md) for production deployment details.

## 🔐 Environment Variables

Key configuration (see `.env.example`):

```bash
# Database
DB_HOST=localhost
DB_USERNAME=postgres
DB_PASSWORD=your_password

# Calendar OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_secret
MICROSOFT_CLIENT_ID=your_microsoft_client_id
MICROSOFT_CLIENT_SECRET=your_microsoft_secret

# Security
JWT_SECRET_KEY=your_jwt_secret
LOCKBOX_MASTER_KEY=your_lockbox_key
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the [Contributing Guidelines](docs/development/CONTRIBUTING.md)
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

- **Documentation**: [`docs/`](docs/) folder
- **Issues**: GitHub Issues
- **API Testing**: Swagger UI at http://localhost:3000/api-docs

---

Built with ❤️ using Ruby on Rails for comprehensive personal AI agent functionality.
