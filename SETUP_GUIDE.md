# Setup Guide

This guide will help you set up and run the Daily AI Agent API on your local machine or server.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby 3.2.x** - [Installation Guide](https://www.ruby-lang.org/en/documentation/installation/)
- **PostgreSQL 12+** - [Download](https://www.postgresql.org/download/)
- **Redis 6+** - [Download](https://redis.io/download)
- **Bundler** - Install with `gem install bundler`

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/kane-nguyen-1217/daily_ai_agent_api.git
cd daily_ai_agent_api
```

### 2. Install Dependencies

```bash
bundle install
```

If you encounter permission issues, you can install gems locally:
```bash
bundle install --path vendor/bundle
```

### 3. Configure Environment Variables

Copy the example environment file and update with your settings:

```bash
cp .env.example .env
```

Edit `.env` and configure the following:

#### Database Configuration
```
DB_HOST=localhost
DB_USERNAME=postgres
DB_PASSWORD=your_password
```

#### JWT Secret
Generate a secret key:
```bash
rails secret
```
Copy the output and set it as `JWT_SECRET_KEY` in `.env`

#### Lockbox Master Key
Generate an encryption key:
```bash
ruby -e "require 'securerandom'; puts SecureRandom.hex(32)"
```
Set it as `LOCKBOX_MASTER_KEY` in `.env`

#### Google OAuth (Optional)
If you want to use Google Calendar/Gmail integration:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable Google Calendar API and Gmail API
4. Create OAuth 2.0 credentials
5. Set the credentials in `.env`:
```
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
GOOGLE_OAUTH_REDIRECT_URI=http://localhost:3000/api/v1/oauth_tokens/google/callback
```

#### Telegram Bot (Optional)
If you want to use Telegram notifications:
1. Create a bot using [@BotFather](https://t.me/botfather) on Telegram
2. Get the bot token
3. Set it in `.env`:
```
TELEGRAM_BOT_TOKEN=your_bot_token
```

#### n8n Integration (Optional)
If you want to use n8n workflow automation:
```
N8N_URL=http://localhost:5678
N8N_API_KEY=your_n8n_api_key
N8N_WEBHOOK_SECRET=your_webhook_secret
```

#### OpenAI/AI Integration (Optional)
If you want to use AI summary generation:
```
OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-3.5-turbo
```

### 4. Set Up the Database

Create and migrate the database:

```bash
# Create databases
rails db:create

# Run migrations
rails db:migrate

# (Optional) Seed with demo data
rails db:seed
```

### 5. Start Redis

Redis is required for Sidekiq background jobs.

**On macOS:**
```bash
brew services start redis
```

**On Linux:**
```bash
sudo systemctl start redis
# or
redis-server
```

**On Windows:**
Use [WSL](https://docs.microsoft.com/en-us/windows/wsl/install) or download Redis for Windows

### 6. Start the Application

Open multiple terminal windows/tabs:

**Terminal 1 - Rails Server:**
```bash
rails server
# or specify a port
rails server -p 3000
```

**Terminal 2 - Sidekiq Worker:**
```bash
bundle exec sidekiq
```

The API should now be running at `http://localhost:3000`

### 7. Test the API

#### Health Check
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2023-11-23T10:00:00.000Z",
  "environment": "development"
}
```

#### Register a User
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "full_name": "Test User"
  }'
```

#### Login
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

Save the `token` from the response and use it for authenticated requests:

```bash
curl http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Troubleshooting

### Database Connection Issues

If you get database connection errors:

1. Ensure PostgreSQL is running:
```bash
# macOS
brew services start postgresql

# Linux
sudo systemctl start postgresql
```

2. Check your database credentials in `.env`

3. Create the database user if needed:
```bash
psql postgres
CREATE USER postgres WITH PASSWORD 'your_password';
ALTER USER postgres CREATEDB;
```

### Redis Connection Issues

Ensure Redis is running:
```bash
redis-cli ping
# Should return: PONG
```

### Missing Gems

If you get "cannot load such file" errors:
```bash
bundle install
```

### Migration Issues

If migrations fail:
```bash
rails db:drop db:create db:migrate
```

**Warning:** This will delete all data!

## Running Tests

(Note: Test infrastructure would be added in a complete implementation)

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb
```

## Production Deployment

For production deployment:

1. Set `RAILS_ENV=production` in your environment
2. Set secure values for all secrets (JWT_SECRET_KEY, LOCKBOX_MASTER_KEY, etc.)
3. Configure a production database
4. Set up a proper web server (e.g., Nginx with Puma)
5. Configure SSL/TLS certificates
6. Set up process monitoring (e.g., systemd, Docker)
7. Configure Redis for production use
8. Set up log rotation
9. Configure CORS for your frontend domain

### Quick Production Setup with Docker

(Docker support would be added in the next iteration)

```bash
docker-compose up -d
```

## API Documentation

See [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) for detailed API endpoint documentation.

## Common Tasks

### Generate New Migration
```bash
rails generate migration AddFieldToTable field:type
rails db:migrate
```

### Rails Console
```bash
rails console
# or for production
rails console -e production
```

### View Logs
```bash
tail -f log/development.log
```

### Reset Database
```bash
rails db:reset
# This drops, creates, migrates, and seeds the database
```

## Support

For issues and questions:
- Check the [README.md](./README.md)
- Review [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
- Open an issue on GitHub

## Next Steps

After setup, explore:
- Creating automation settings
- Setting up scheduler jobs
- Linking Telegram accounts
- Configuring OAuth for Google services
- Setting up crypto price alerts
- Generating AI summaries
