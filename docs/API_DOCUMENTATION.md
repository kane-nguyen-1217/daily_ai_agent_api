# API Documentation

## Base URL
```
Development: http://localhost:3000
Production: https://your-domain.com
```

## Authentication

All authenticated endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## Response Format

### Success Response
```json
{
  "message": "Success message",
  "data": { ... }
}
```

### Error Response
```json
{
  "error": "Error message",
  "errors": ["Detailed error 1", "Detailed error 2"]
}
```

## Endpoints

### 1. Authentication

#### 1.1 Register
Create a new user account.

**Endpoint:** `POST /api/v1/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "full_name": "John Doe",
  "timezone": "America/New_York"
}
```

**Response (201 Created):**
```json
{
  "message": "User created successfully",
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "timezone": "America/New_York",
    "active": true,
    "created_at": "2023-11-23T10:00:00.000Z"
  }
}
```

#### 1.2 Login
Authenticate and get access token.

**Endpoint:** `POST /api/v1/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": { ... }
}
```

#### 1.3 Refresh Token
Refresh an expired access token.

**Endpoint:** `POST /api/v1/auth/refresh`

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Response (200 OK):**
```json
{
  "message": "Token refreshed successfully",
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

#### 1.4 Logout
Logout the current user.

**Endpoint:** `POST /api/v1/auth/logout`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "message": "Logout successful"
}
```

### 2. User Profile

#### 2.1 Get Profile
Get current user's profile information.

**Endpoint:** `GET /api/v1/users/profile`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "timezone": "America/New_York",
    "active": true,
    "last_login_at": "2023-11-23T10:00:00.000Z",
    "created_at": "2023-11-23T09:00:00.000Z",
    "updated_at": "2023-11-23T10:00:00.000Z"
  }
}
```

#### 2.2 Update Profile
Update user profile information.

**Endpoint:** `PUT /api/v1/users/profile`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "full_name": "Jane Doe",
  "timezone": "Europe/London",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

### 3. OAuth Tokens

#### 3.1 List OAuth Tokens
Get all OAuth tokens for the current user.

**Endpoint:** `GET /api/v1/oauth_tokens`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "oauth_tokens": [
    {
      "id": 1,
      "provider": "google",
      "scope": "https://www.googleapis.com/auth/calendar",
      "expires_at": "2024-11-23T10:00:00.000Z",
      "expired": false,
      "created_at": "2023-11-23T10:00:00.000Z"
    }
  ]
}
```

#### 3.2 Google Authorization URL
Get Google OAuth authorization URL.

**Endpoint:** `GET /api/v1/oauth_tokens/google/authorize`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `redirect_uri` (optional): OAuth redirect URI
- `scope` (optional): OAuth scopes

**Response (200 OK):**
```json
{
  "authorization_url": "https://accounts.google.com/o/oauth2/auth?..."
}
```

#### 3.3 Google OAuth Callback
Process Google OAuth callback and save tokens.

**Endpoint:** `POST /api/v1/oauth_tokens/google/callback`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "code": "authorization_code_from_google",
  "redirect_uri": "http://localhost:3000/callback"
}
```

### 4. Telegram Links

#### 4.1 Create Telegram Link
Link a Telegram account to the user.

**Endpoint:** `POST /api/v1/telegram_links`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "telegram_user_id": "123456789",
  "telegram_username": "johndoe"
}
```

**Response (201 Created):**
```json
{
  "message": "Telegram link created successfully. Please verify using the code.",
  "telegram_link": {
    "id": 1,
    "telegram_user_id": "123456789",
    "telegram_username": "johndoe",
    "verified": false,
    "active": true,
    "created_at": "2023-11-23T10:00:00.000Z"
  },
  "verification_code": "ABC123"
}
```

#### 4.2 Verify Telegram Link
Verify a Telegram link using the verification code.

**Endpoint:** `POST /api/v1/telegram_links/verify`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "id": 1,
  "verification_code": "ABC123"
}
```

### 5. Automation Settings

#### 5.1 List Automation Settings
Get all automation settings for the current user.

**Endpoint:** `GET /api/v1/automation_settings`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `enabled` (optional): Filter by enabled status (true/false)
- `type` (optional): Filter by automation type

**Response (200 OK):**
```json
{
  "automation_settings": [
    {
      "id": 1,
      "name": "Daily Calendar Sync",
      "automation_type": "calendar",
      "configuration": {
        "sync_frequency": "daily",
        "notification_enabled": true
      },
      "enabled": true,
      "priority": 1,
      "created_at": "2023-11-23T10:00:00.000Z",
      "updated_at": "2023-11-23T10:00:00.000Z"
    }
  ]
}
```

#### 5.2 Create Automation Setting
Create a new automation setting.

**Endpoint:** `POST /api/v1/automation_settings`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Crypto Price Alerts",
  "automation_type": "crypto",
  "configuration": {
    "symbols": ["BTC", "ETH"],
    "alert_threshold": 5.0
  },
  "enabled": true,
  "priority": 2
}
```

### 6. Scheduler Jobs

#### 6.1 List Scheduler Jobs
Get all scheduler jobs for the current user.

**Endpoint:** `GET /api/v1/scheduler_jobs`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "scheduler_jobs": [
    {
      "id": 1,
      "name": "Daily Summary",
      "job_type": "daily_summary",
      "schedule": "0 8 * * *",
      "job_parameters": {
        "include_crypto": true,
        "include_calendar": true
      },
      "enabled": true,
      "last_run_at": "2023-11-23T08:00:00.000Z",
      "next_run_at": "2023-11-24T08:00:00.000Z",
      "last_status": "success",
      "last_error": null,
      "created_at": "2023-11-23T10:00:00.000Z",
      "updated_at": "2023-11-23T10:00:00.000Z"
    }
  ]
}
```

#### 6.2 Run Job Now
Execute a scheduler job immediately.

**Endpoint:** `POST /api/v1/scheduler_jobs/:id/run`

**Headers:** `Authorization: Bearer <token>`

#### 6.3 Enable/Disable Job
Enable or disable a scheduler job.

**Endpoint:** `PUT /api/v1/scheduler_jobs/:id/enable`
**Endpoint:** `PUT /api/v1/scheduler_jobs/:id/disable`

**Headers:** `Authorization: Bearer <token>`

### 7. AI Summaries

#### 7.1 Generate AI Summary
Generate a new AI summary.

**Endpoint:** `POST /api/v1/ai_summaries/generate`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "summary_type": "daily",
  "summary_date": "2023-11-23",
  "ai_model": "gpt-3.5-turbo"
}
```

**Response (202 Accepted):**
```json
{
  "message": "AI summary generation queued",
  "ai_summary": {
    "id": 1,
    "summary_type": "daily",
    "summary_date": "2023-11-23",
    "status": "pending",
    "ai_model": "gpt-3.5-turbo",
    "created_at": "2023-11-23T10:00:00.000Z"
  }
}
```

### 8. Crypto Data

#### 8.1 Get Current Prices
Get current cryptocurrency prices.

**Endpoint:** `GET /api/v1/crypto_data/prices`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `symbols` (optional): Comma-separated list of crypto symbols (default: BTC,ETH,SOL,ADA,DOT)

**Response (200 OK):**
```json
{
  "prices": [
    {
      "symbol": "BTC",
      "price": 43250.50,
      "change_24h": 2.5,
      "cached_at": "2023-11-23T10:00:00.000Z"
    }
  ]
}
```

### 9. Alerts

#### 9.1 List Alerts
Get alerts for the current user.

**Endpoint:** `GET /api/v1/alerts`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `alert_type` (optional): Filter by alert type
- `severity` (optional): Filter by severity (info/warning/critical)
- `unacknowledged` (optional): Show only unacknowledged alerts (true/false)

**Response (200 OK):**
```json
{
  "alerts": [
    {
      "id": 1,
      "alert_type": "crypto_price",
      "title": "Bitcoin Price Alert",
      "message": "BTC price increased by 5%",
      "severity": "info",
      "metadata": {
        "symbol": "BTC",
        "price": 43250.50
      },
      "acknowledged": false,
      "acknowledged_at": null,
      "sent": true,
      "sent_at": "2023-11-23T10:00:00.000Z",
      "created_at": "2023-11-23T10:00:00.000Z"
    }
  ]
}
```

#### 9.2 Acknowledge Alert
Mark an alert as acknowledged.

**Endpoint:** `PUT /api/v1/alerts/:id/acknowledge`

**Headers:** `Authorization: Bearer <token>`

### 10. n8n Webhooks

#### 10.1 Execute Workflow
Execute an n8n workflow.

**Endpoint:** `POST /api/v1/webhooks/n8n/execute`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "workflow_id": "workflow_123",
  "workflow_params": {
    "param1": "value1",
    "param2": "value2"
  }
}
```

**Response (202 Accepted):**
```json
{
  "message": "Workflow execution started",
  "execution_id": "exec_456",
  "log_id": 1,
  "status_url": "/api/v1/webhooks/n8n/status/exec_456"
}
```

#### 10.2 Check Execution Status
Check the status of a workflow execution.

**Endpoint:** `GET /api/v1/webhooks/n8n/status/:job_id`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "execution_id": "exec_456",
  "status": "success",
  "response": { ... },
  "error": null,
  "executed_at": "2023-11-23T10:00:00.000Z",
  "updated_at": "2023-11-23T10:01:00.000Z"
}
```

## Status Codes

- `200 OK`: Request successful
- `201 Created`: Resource created successfully
- `202 Accepted`: Request accepted for processing
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Missing or invalid authentication token
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation error
- `500 Internal Server Error`: Server error

## Rate Limiting

API rate limits apply per user:
- 100 requests per minute for authenticated users
- 10 requests per minute for unauthenticated endpoints

## Pagination

List endpoints support pagination:
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 20, max: 100)

Example: `GET /api/v1/alerts?page=2&per_page=50`
