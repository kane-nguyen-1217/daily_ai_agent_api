# Daily AI Agent API

A comprehensive Ruby on Rails backend API for a multi-user Personal AI Agent platform. This API provides endpoints for user authentication, OAuth integration, Telegram linking, automation settings, scheduled jobs, AI summary generation, crypto data fetching, alert management, and n8n integration.

## Features

- **User Authentication**: JWT-based authentication with refresh tokens
- **OAuth Integration**: Google Calendar and Gmail OAuth token management
- **Telegram Integration**: Link and verify Telegram accounts for notifications
- **Automation Settings**: Configure various automation types (calendar, email, crypto, etc.)
- **Scheduler Jobs**: Daily scheduler with cron-like syntax for recurring tasks
- **AI Summaries**: Generate AI-powered daily/weekly/monthly summaries
- **Crypto Data**: Real-time cryptocurrency price tracking and alerts
- **Alert System**: Multi-severity alert system with notification support
- **n8n Integration**: Webhook callbacks and workflow execution

## Technology Stack

- **Ruby**: 3.2.x
- **Rails**: 7.0.x
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq with Redis
- **Authentication**: JWT tokens
- **Encryption**: Lockbox for sensitive data
- **HTTP Client**: HTTParty for external API calls

## Setup

### Prerequisites

- Ruby 3.2.x
- PostgreSQL
- Redis (for Sidekiq)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/kane-nguyen-1217/daily_ai_agent_api.git
cd daily_ai_agent_api
```

2. Install dependencies:
```bash
bundle install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Create and migrate the database:
```bash
rails db:create
rails db:migrate
```

5. Start the server:
```bash
rails server
```

6. Start Sidekiq for background jobs:
```bash
bundle exec sidekiq
```

## API Documentation

### Authentication Endpoints

#### Register
```
POST /api/v1/auth/register
Body: { email, password, password_confirmation, full_name, timezone }
```

#### Login
```
POST /api/v1/auth/login
Body: { email, password }
```

#### Refresh Token
```
POST /api/v1/auth/refresh
Body: { refresh_token }
```

#### Logout
```
POST /api/v1/auth/logout
Headers: Authorization: Bearer <token>
```

### User Profile

#### Get Profile
```
GET /api/v1/users/profile
Headers: Authorization: Bearer <token>
```

#### Update Profile
```
PUT /api/v1/users/profile
Headers: Authorization: Bearer <token>
Body: { full_name, timezone, password, password_confirmation }
```

### OAuth Tokens (Google Calendar/Gmail)

#### List OAuth Tokens
```
GET /api/v1/oauth_tokens
Headers: Authorization: Bearer <token>
```

#### Get Google Authorization URL
```
GET /api/v1/oauth_tokens/google/authorize
Headers: Authorization: Bearer <token>
Query: { redirect_uri, scope }
```

#### Google OAuth Callback
```
POST /api/v1/oauth_tokens/google/callback
Headers: Authorization: Bearer <token>
Body: { code, redirect_uri }
```

#### Delete OAuth Token
```
DELETE /api/v1/oauth_tokens/:id
Headers: Authorization: Bearer <token>
```

### Telegram Links

#### List Telegram Links
```
GET /api/v1/telegram_links
Headers: Authorization: Bearer <token>
```

#### Create Telegram Link
```
POST /api/v1/telegram_links
Headers: Authorization: Bearer <token>
Body: { telegram_user_id, telegram_username }
```

#### Verify Telegram Link
```
POST /api/v1/telegram_links/verify
Headers: Authorization: Bearer <token>
Body: { id, verification_code }
```

### Automation Settings

#### List Automation Settings
```
GET /api/v1/automation_settings
Headers: Authorization: Bearer <token>
Query: { enabled, type }
```

#### Create Automation Setting
```
POST /api/v1/automation_settings
Headers: Authorization: Bearer <token>
Body: { name, automation_type, configuration, enabled, priority }
```

#### Update Automation Setting
```
PUT /api/v1/automation_settings/:id
Headers: Authorization: Bearer <token>
Body: { name, automation_type, configuration, enabled, priority }
```

### Scheduler Jobs

#### List Scheduler Jobs
```
GET /api/v1/scheduler_jobs
Headers: Authorization: Bearer <token>
```

#### Create Scheduler Job
```
POST /api/v1/scheduler_jobs
Headers: Authorization: Bearer <token>
Body: { name, job_type, schedule, job_parameters, enabled }
```

#### Run Job Now
```
POST /api/v1/scheduler_jobs/:id/run
Headers: Authorization: Bearer <token>
```

#### Enable/Disable Job
```
PUT /api/v1/scheduler_jobs/:id/enable
PUT /api/v1/scheduler_jobs/:id/disable
Headers: Authorization: Bearer <token>
```

### AI Summaries

#### List AI Summaries
```
GET /api/v1/ai_summaries
Headers: Authorization: Bearer <token>
```

#### Generate AI Summary
```
POST /api/v1/ai_summaries/generate
Headers: Authorization: Bearer <token>
Body: { summary_type, summary_date, ai_model }
```

### Crypto Data

#### Get Current Prices
```
GET /api/v1/crypto_data/prices
Headers: Authorization: Bearer <token>
Query: { symbols: "BTC,ETH,SOL" }
```

#### Get Historical Data
```
GET /api/v1/crypto_data/historical/:symbol
Headers: Authorization: Bearer <token>
Query: { days: 7 }
```

### Alerts

#### List Alerts
```
GET /api/v1/alerts
Headers: Authorization: Bearer <token>
Query: { alert_type, severity, unacknowledged }
```

#### Create Alert
```
POST /api/v1/alerts
Headers: Authorization: Bearer <token>
Body: { alert_type, title, message, severity, metadata }
```

#### Acknowledge Alert
```
PUT /api/v1/alerts/:id/acknowledge
Headers: Authorization: Bearer <token>
```

### n8n Webhooks

#### Workflow Callback
```
POST /api/v1/webhooks/n8n/workflow
Headers: X-N8N-Signature: <signature>
Body: { workflow_id, execution_id, user_id, ... }
```

#### Execute Workflow
```
POST /api/v1/webhooks/n8n/execute
Headers: Authorization: Bearer <token>
Body: { workflow_id, workflow_params }
```

#### Check Execution Status
```
GET /api/v1/webhooks/n8n/status/:job_id
Headers: Authorization: Bearer <token>
```

## Security Features

- JWT token-based authentication
- Encrypted storage of OAuth tokens using Lockbox
- Secure password hashing with bcrypt
- CORS configuration
- Request parameter filtering for sensitive data
- n8n webhook signature verification

## Background Jobs

The following background jobs are implemented using Sidekiq:

- **SchedulerJobWorker**: Executes scheduled jobs (daily summaries, crypto checks, etc.)
- **AiSummaryWorker**: Generates AI summaries asynchronously
- **N8nWebhookProcessorWorker**: Processes n8n webhook callbacks

## Environment Variables

See `.env.example` for required environment variables including:
- Database configuration
- JWT secret key
- OAuth credentials (Google)
- Telegram bot token
- n8n integration settings
- Crypto API configuration
- OpenAI API key

## License

This project is licensed under the MIT License.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
