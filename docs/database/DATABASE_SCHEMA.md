# Database Schema Documentation

## Overview

This document provides a comprehensive overview of the Daily AI Agent API database schema, including table structures, relationships, and field explanations.

## Database Statistics

- **Total Tables**: 12
- **Migration Version**: 20251125143906
- **Database**: PostgreSQL
- **Primary Key Type**: bigint (auto-increment)

## Schema Diagram

```
                                    ┌─────────────────┐
                                    │      USERS      │
                                    │                 │
                                    │ • id (PK)       │
                                    │ • email         │
                                    │ • password_digest│
                                    │ • full_name     │
                                    │ • timezone      │
                                    │ • digest_hour   │
                                    │ • active        │
                                    │ • last_login_at │
                                    └─────────┬───────┘
                                              │
                                              │ 1:N (has_many)
                ┌─────────────────────────────┼─────────────────────────────┐
                │                             │                             │
                │                             │                             │
        ┌───────▼──────┐              ┌──────▼──────┐              ┌─────▼─────┐
        │ OAUTH_TOKENS │              │CALENDAR_ACCTS│              │NOTIFICATIONS│
        │              │              │              │              │           │
        │• id (PK)     │              │• id (PK)     │              │• id (PK)  │
        │• user_id (FK)│              │• user_id (FK)│              │• user_id  │
        │• provider    │              │• provider    │              │• title    │
        │• access_token│              │• email       │              │• body     │
        │• refresh_token│             │• access_token│              │• data     │
        │• expires_at  │              │• refresh_token│             │• read_at  │
        │• scope       │              │• expires_at  │              └───────────┘
        │• token_metadata│            │• meta        │
        └──────────────┘              │• active      │
                                      └──────────────┘
                │                             │                             │
                │                             │                             │
        ┌───────▼──────┐              ┌──────▼──────┐              ┌─────▼─────┐
        │TELEGRAM_LINKS│              │AUTOMATION_  │              │   ALERTS  │
        │              │              │  SETTINGS   │              │           │
        │• id (PK)     │              │              │              │• id (PK)  │
        │• user_id (FK)│              │• id (PK)     │              │• user_id  │
        │• telegram_   │              │• user_id (FK)│              │• alert_type│
        │  user_id     │              │• name        │              │• title    │
        │• telegram_   │              │• automation_ │              │• message  │
        │  username    │              │  type        │              │• severity │
        │• verification│              │• configuration│             │• metadata │
        │  _code       │              │• enabled     │              │• acknowledged│
        │• verified    │              │• priority    │              │• sent     │
        │• verified_at │              └──────────────┘              └───────────┘
        │• active      │
        └──────────────┘
                │                             │                             │
                │                             │                             │
        ┌───────▼──────┐              ┌──────▼──────┐              ┌─────▼─────┐
        │SCHEDULER_JOBS│              │AI_SUMMARIES │              │CRYPTO_DATA│
        │              │              │             │              │  _CACHES  │
        │• id (PK)     │              │• id (PK)    │              │           │
        │• user_id (FK)│              │• user_id(FK)│              │• id (PK)  │
        │• name        │              │• summary_type│             │• symbol   │
        │• schedule    │              │• summary_date│             │• price    │
        │• job_parameters│            │• content    │              │• market_cap│
        │• enabled     │              │• source_data│              │• volume_24h│
        │• last_run_at │              │• ai_model   │              │• change_24h│
        │• next_run_at │              │• token_count│              │• change_7d │
        │• last_status │              │• status     │              │• cached_at │
        │• last_error  │              └─────────────┘              └───────────┘
        └──────────────┘
                │
                │
        ┌───────▼──────┐
        │N8N_WEBHOOK   │
        │    _LOGS     │
        │              │
        │• id (PK)     │
        │• user_id (FK)│
        │• workflow_id │
        │• payload     │
        │• response    │
        │• status      │
        │• processed_at│
        └──────────────┘
```

---

## Table Definitions

### 1. users

**Purpose**: Core user accounts and authentication
**Relationships**: Central hub - has many relationships to all other tables

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `email` | string | NOT NULL, UNIQUE | User's email address (used for login) |
| `password_digest` | string | NOT NULL | Encrypted password using bcrypt |
| `full_name` | string | nullable | User's display name |
| `timezone` | string | default: 'Asia/Ho_Chi_Minh' | User's timezone for scheduling |
| `digest_hour` | integer | default: 8 | Hour (0-23) to send daily calendar digest |
| `active` | boolean | default: true | Account status (soft delete) |
| `last_login_at` | datetime | nullable | Last successful login timestamp |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_users_on_email` (UNIQUE)

**Associations**:
```ruby
has_many :oauth_tokens, dependent: :destroy
has_many :telegram_links, dependent: :destroy
has_many :automation_settings, dependent: :destroy
has_many :scheduler_jobs, dependent: :destroy
has_many :ai_summaries, dependent: :destroy
has_many :alerts, dependent: :destroy
has_many :calendar_accounts, dependent: :destroy
has_many :notifications, dependent: :destroy
```

---

### 2. oauth_tokens

**Purpose**: Store encrypted OAuth tokens for external service integration
**Relationships**: belongs_to :user

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `user_id` | bigint | NOT NULL, FK | Reference to users table |
| `provider` | string | NOT NULL | OAuth provider ('google', 'gmail', 'calendar') |
| `access_token_ciphertext` | text | nullable | Encrypted access token |
| `refresh_token_ciphertext` | text | nullable | Encrypted refresh token |
| `expires_at` | datetime | nullable | Token expiration timestamp |
| `scope` | string | nullable | Granted OAuth scopes |
| `token_metadata` | json | nullable | Additional provider-specific data |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_oauth_tokens_on_user_id_and_provider` (UNIQUE)

**Security**: Uses Lockbox encryption for sensitive token fields

---

### 3. calendar_accounts

**Purpose**: Store encrypted calendar provider connections (Google/Microsoft)
**Relationships**: belongs_to :user

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `user_id` | bigint | NOT NULL, FK | Reference to users table |
| `provider` | string | NOT NULL | Calendar provider ('google', 'microsoft') |
| `email` | string | nullable | Associated calendar email address |
| `access_token` | text | nullable, encrypted | OAuth access token for API calls |
| `refresh_token` | text | nullable, encrypted | OAuth refresh token for renewal |
| `expires_at` | datetime | nullable | Token expiration timestamp |
| `meta` | jsonb | default: {} | Provider-specific metadata |
| `active` | boolean | default: true | Connection status |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_calendar_accounts_on_user_id_and_provider_and_email` (UNIQUE)
- `index_calendar_accounts_on_provider`
- `index_calendar_accounts_on_active`

**Security**: Uses Rails 7 `encrypts` for access_token and refresh_token fields

---

### 4. notifications

**Purpose**: In-app notification system for calendar digests and alerts
**Relationships**: belongs_to :user

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `user_id` | bigint | NOT NULL, FK | Reference to users table |
| `title` | string | NOT NULL | Notification headline |
| `body` | text | nullable | Notification detailed message |
| `data` | jsonb | default: {} | Structured notification data (e.g., calendar events) |
| `read_at` | datetime | nullable | When user read the notification |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_notifications_on_user_id`
- `index_notifications_on_user_id_and_read_at`
- `index_notifications_on_created_at`

**Usage Examples**:
- Daily calendar digest notifications
- Calendar reconnection required alerts
- System notifications

---

### 5. telegram_links

**Purpose**: Link user accounts to Telegram for notification delivery
**Relationships**: belongs_to :user

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `user_id` | bigint | NOT NULL, FK | Reference to users table |
| `telegram_user_id` | string | NOT NULL, UNIQUE | Telegram user ID |
| `telegram_username` | string | nullable | Telegram @username |
| `verification_code` | string | nullable | 6-digit verification code |
| `verified` | boolean | default: false | Link verification status |
| `verified_at` | datetime | nullable | Verification completion timestamp |
| `active` | boolean | default: true | Link active status |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_telegram_links_on_telegram_user_id` (UNIQUE)
- `index_telegram_links_on_user_id_and_active`

---

### 6. automation_settings

**Purpose**: User-defined automation configurations
**Relationships**: belongs_to :user

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `user_id` | bigint | NOT NULL, FK | Reference to users table |
| `name` | string | NOT NULL | Human-readable automation name |
| `automation_type` | string | NOT NULL | Type of automation ('calendar', 'email', 'crypto', 'summary', 'alert') |
| `configuration` | json | nullable | Automation-specific settings |
| `enabled` | boolean | default: true | Automation active status |
| `priority` | integer | default: 0 | Execution priority order |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_automation_settings_on_user_id_and_automation_type`
- `index_automation_settings_on_enabled`

---

### 7. scheduler_jobs

**Purpose**: Cron-based scheduled tasks for users
**Relationships**: belongs_to :user

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `user_id` | bigint | NOT NULL, FK | Reference to users table |
| `name` | string | NOT NULL | Job display name |
| `job_type` | string | NOT NULL | Job category ('daily_summary', 'crypto_check', 'calendar_sync') |
| `schedule` | string | NOT NULL | Cron expression format |
| `job_parameters` | json | nullable | Job-specific configuration |
| `enabled` | boolean | default: true | Job active status |
| `last_run_at` | datetime | nullable | Last execution timestamp |
| `next_run_at` | datetime | nullable | Next scheduled execution |
| `last_status` | string | nullable | Last execution result ('success', 'failed', 'running') |
| `last_error` | text | nullable | Error message from last failed run |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_scheduler_jobs_on_user_id_and_enabled`
- `index_scheduler_jobs_on_next_run_at`
- `index_scheduler_jobs_on_job_type`

---

### 8. ai_summaries

**Purpose**: Store AI-generated summaries and analysis
**Relationships**: belongs_to :user

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `user_id` | bigint | NOT NULL, FK | Reference to users table |
| `summary_type` | string | NOT NULL | Summary category ('daily', 'weekly', 'monthly', 'custom') |
| `summary_date` | date | nullable | Date the summary covers |
| `content` | text | nullable | Generated summary content |
| `source_data` | json | nullable | Input data used for generation |
| `ai_model` | string | nullable | AI model used ('gpt-4', 'gpt-3.5-turbo') |
| `token_count` | integer | nullable | Number of tokens consumed |
| `status` | string | default: 'pending' | Generation status ('pending', 'generating', 'completed', 'failed') |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_ai_summaries_on_user_id_and_summary_date`
- `index_ai_summaries_on_summary_type`
- `index_ai_summaries_on_status`

---

### 9. alerts

**Purpose**: User-specific alerts and notifications
**Relationships**: belongs_to :user

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `user_id` | bigint | NOT NULL, FK | Reference to users table |
| `alert_type` | string | NOT NULL | Alert category ('crypto_price', 'calendar_event', 'task_reminder') |
| `title` | string | NOT NULL | Alert headline |
| `message` | text | nullable | Alert detailed message |
| `severity` | string | default: 'info' | Alert importance ('info', 'warning', 'critical') |
| `metadata` | json | nullable | Alert-specific data |
| `acknowledged` | boolean | default: false | User acknowledgment status |
| `acknowledged_at` | datetime | nullable | Acknowledgment timestamp |
| `sent` | boolean | default: false | Delivery status |
| `sent_at` | datetime | nullable | Delivery timestamp |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_alerts_on_user_id_and_acknowledged`
- `index_alerts_on_user_id_and_created_at`
- `index_alerts_on_alert_type`
- `index_alerts_on_severity`

---

### 10. crypto_data_caches

**Purpose**: Cached cryptocurrency market data (shared across users)
**Relationships**: No foreign keys (standalone table)

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `symbol` | string | NOT NULL, UNIQUE | Cryptocurrency symbol (e.g., 'BTC', 'ETH') |
| `price` | decimal | nullable | Current price in USD |
| `market_cap` | bigint | nullable | Market capitalization |
| `volume_24h` | bigint | nullable | 24-hour trading volume |
| `change_24h` | decimal | nullable | 24-hour price change percentage |
| `change_7d` | decimal | nullable | 7-day price change percentage |
| `cached_at` | datetime | nullable | Data freshness timestamp |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_crypto_data_caches_on_symbol` (UNIQUE)
- `index_crypto_data_caches_on_cached_at`

**Note**: This table is shared across all users for efficiency

---

### 11. n8n_webhook_logs

**Purpose**: Log n8n workflow integration requests
**Relationships**: belongs_to :user (optional)

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `id` | bigint | PRIMARY KEY | Auto-incrementing unique identifier |
| `user_id` | bigint | nullable, FK | Reference to users table (optional) |
| `workflow_id` | string | NOT NULL | n8n workflow identifier |
| `payload` | json | nullable | Incoming webhook payload |
| `response` | json | nullable | Processing response data |
| `status` | string | default: 'pending' | Processing status ('pending', 'running', 'success', 'failed') |
| `processed_at` | datetime | nullable | Processing completion timestamp |
| `created_at` | datetime | NOT NULL | Record creation timestamp |
| `updated_at` | datetime | NOT NULL | Record last update timestamp |

**Indexes**:
- `index_n8n_webhook_logs_on_user_id`
- `index_n8n_webhook_logs_on_workflow_id`
- `index_n8n_webhook_logs_on_status`

---

## Foreign Key Relationships

All foreign key relationships cascade appropriately:

```sql
-- User-dependent tables (cascade delete)
add_foreign_key "oauth_tokens", "users"
add_foreign_key "telegram_links", "users"
add_foreign_key "automation_settings", "users"
add_foreign_key "scheduler_jobs", "users"
add_foreign_key "ai_summaries", "users"
add_foreign_key "alerts", "users"
add_foreign_key "calendar_accounts", "users"
add_foreign_key "notifications", "users"
add_foreign_key "n8n_webhook_logs", "users"
```

## Security Features

### 1. **Encryption at Rest**
- OAuth tokens encrypted using Lockbox
- Calendar tokens encrypted using Rails 7 `encrypts`

### 2. **Data Isolation**
- All user data isolated by `user_id`
- No cross-user data access possible

### 3. **Soft Deletes**
- `active` flags prevent hard deletes
- Data preservation for audit trails

### 4. **Index Optimization**
- Composite indexes for common user queries
- Performance indexes on frequently filtered fields

## Usage Patterns

### **Calendar Integration Flow**:
1. User authenticates → `users`
2. Connects calendar → `calendar_accounts` 
3. System fetches events → API calls using encrypted tokens
4. Generates digest → `notifications`
5. User receives notification → read tracking

### **Automation Flow**:
1. User configures automation → `automation_settings`
2. System creates scheduled job → `scheduler_jobs`
3. Job executes → updates `last_run_at`, `last_status`
4. Results stored → `ai_summaries`, `alerts`, `notifications`

### **Alert Flow**:
1. System detects event → creates `alerts`
2. Sends via Telegram → uses `telegram_links`
3. Creates notification → `notifications`
4. User acknowledges → updates `acknowledged_at`

This schema provides a robust foundation for a multi-user AI agent platform with comprehensive calendar integration, automation capabilities, and secure data handling.
