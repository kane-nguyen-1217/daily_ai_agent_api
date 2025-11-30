# Calendar Integration & Daily Digest System

## Overview

This system allows users to connect multiple calendar providers (Google and Microsoft) and receive daily digest notifications containing their aggregated calendar events.

## Features

- ✅ Multi-provider calendar support (Google & Microsoft)
- ✅ Secure token encryption at rest
- ✅ Automatic token refresh
- ✅ Daily digest notifications at user-specified time
- ✅ Timezone-aware scheduling
- ✅ Event aggregation across all connected calendars
- ✅ Graceful error handling with user notifications
- ✅ Rate limiting protection

## Architecture

### Models

#### CalendarAccount
- Stores encrypted calendar provider credentials
- Supports Google Calendar and Microsoft Calendar
- Fields: `user_id`, `provider`, `email`, `access_token` (encrypted), `refresh_token` (encrypted), `expires_at`, `meta`, `active`

#### Notification
- In-app notification system
- Fields: `user_id`, `title`, `body`, `data` (jsonb), `read_at`

#### User (Extended)
- Added fields: `digest_hour` (default: 8), `timezone` (default: 'Asia/Ho_Chi_Minh')

### Services

#### CalendarAccountCreator
Creates or updates calendar account connections after OAuth callback.

```ruby
CalendarAccountCreator.call(
  user: user,
  provider: 'google',
  token_response: { access_token:, refresh_token:, expires_in:, scope: },
  profile: { email:, name:, picture: }
)
```

#### CalendarEventsFetcher
Fetches calendar events for a specific day, handling timezone conversion.

```ruby
events = CalendarEventsFetcher.fetch_for_day(
  calendar_account: account,
  date: Date.today,
  tz: 'America/New_York'
)
```

Returns normalized event array:
```ruby
[
  {
    provider: 'google',
    provider_event_id: '...',
    title: 'Meeting with team',
    start_at: Time,
    end_at: Time,
    all_day: false,
    organizer_email: 'organizer@example.com',
    raw: { ... }
  }
]
```

#### AppNotificationService
Creates in-app notifications for users.

```ruby
AppNotificationService.notify(
  user: user,
  title: 'Your Calendar for Today',
  body: 'You have 5 events today',
  data: { type: 'daily_calendar_digest', events: [...] }
)
```

### Workers

#### DailyCalendarDigestWorker
Sidekiq worker that:
1. Fetches events from all active calendar accounts
2. Aggregates and sorts events by start time
3. Sends notification with event summary

```ruby
DailyCalendarDigestWorker.perform_async(user_id, date_string)
```

### Controllers

#### Api::V1::CalendarController

**OAuth Connect**
```
GET /api/v1/calendar/:provider/connect
Authorization: Bearer <token>

Response:
{
  "authorization_url": "https://accounts.google.com/o/oauth2/v2/auth?..."
}
```

**OAuth Callback**
```
GET /api/v1/calendar/:provider/callback?code=...&state=...

Redirects to: {FRONTEND_URL}/calendar/connected?provider=google&status=success
```

## Setup Instructions

### 1. Environment Variables

Add to `.env`:

```bash
# Google Calendar OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Microsoft Calendar OAuth  
MICROSOFT_CLIENT_ID=your_microsoft_client_id
MICROSOFT_CLIENT_SECRET=your_microsoft_client_secret

# Frontend URL for OAuth redirects
FRONTEND_URL=http://localhost:3001
```

### 2. Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Calendar API
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
5. Add authorized redirect URI: `http://localhost:3000/api/v1/calendar/google/callback`
6. Copy Client ID and Client Secret to `.env`

Required Scopes:
- `openid`
- `email`
- `profile`
- `https://www.googleapis.com/auth/calendar.readonly`

### 3. Microsoft OAuth Setup

1. Go to [Azure Portal](https://portal.azure.com/)
2. Navigate to "Azure Active Directory" → "App registrations"
3. Create new registration
4. Add redirect URI: `http://localhost:3000/api/v1/calendar/microsoft/callback`
5. Go to "Certificates & secrets" → create client secret
6. Go to "API permissions" → Add Microsoft Graph permissions:
   - `Calendars.Read`
   - `offline_access`
   - `openid`
   - `profile`
7. Copy Application (client) ID and client secret to `.env`

### 4. Database Migration

```bash
rails db:migrate
```

This creates:
- `calendar_accounts` table
- `notifications` table
- Adds `digest_hour` to `users` table

### 5. Cron Schedule

Add to your cron scheduler (e.g., `whenever`, `sidekiq-cron`, or system cron):

```ruby
# Run every 15 minutes
*/15 * * * * cd /path/to/app && rails calendar:enqueue_daily_digests RAILS_ENV=production
```

**Using Sidekiq-Cron:**

Add to `config/initializers/sidekiq.rb`:

```ruby
Sidekiq::Cron::Job.create(
  name: 'Calendar Digest Enqueuer',
  cron: '*/15 * * * *',
  class: 'CalendarDigestEnqueuerWorker'
)
```

**Using Whenever:**

Add to `config/schedule.rb`:

```ruby
every 15.minutes do
  rake "calendar:enqueue_daily_digests"
end
```

Then run: `whenever --update-crontab`

## Usage Flow

### 1. User Connects Calendar

```javascript
// Frontend initiates OAuth
GET /api/v1/calendar/google/connect
Authorization: Bearer <user_token>

// Response contains authorization_url
// Redirect user to authorization_url

// After user authorizes, Google redirects to:
GET /api/v1/calendar/google/callback?code=...&state=...

// Backend creates CalendarAccount and redirects to frontend
// Redirect: http://localhost:3001/calendar/connected?provider=google&status=success
```

### 2. Automatic Daily Digest

Every 15 minutes, the cron job runs:
1. Iterates through all users
2. Checks if user's local time matches their `digest_hour` (default: 8 AM)
3. Enqueues `DailyCalendarDigestWorker` for matching users
4. Worker fetches events from all connected calendars
5. Sends notification with aggregated events

### 3. Token Refresh

When fetching events:
1. `CalendarAccount#ensure_access_token!` checks if token is expired
2. If expired, automatically refreshes using refresh_token
3. If refresh fails:
   - Marks account as `active: false`
   - Sends notification to user to reconnect
   - Does not crash the digest process

## Security

### Token Encryption

Access tokens and refresh tokens are encrypted at rest using Rails 7's built-in encryption:

```ruby
class CalendarAccount < ApplicationRecord
  encrypts :access_token, :refresh_token
end
```

### Consent Tracking

Consent timestamp stored in `meta` field:

```ruby
meta: {
  consented_at: "2025-11-25T14:30:00Z",
  profile_name: "John Doe",
  scopes: "openid email profile calendar.readonly"
}
```

## Error Handling

### Rate Limiting (429)
- Logged as warning
- Sidekiq automatically retries with exponential backoff
- Does not mark account as inactive

### Token Refresh Failure
- Marks account as `active: false`
- Sends notification to user
- Logs error with user_id and calendar_account_id
- Does not crash digest for other accounts

### API Errors
- Logged with full context
- Continues processing other accounts
- Retried by Sidekiq (max 3 attempts)

## Testing

### Manual Testing

**Test OAuth Flow:**
```bash
# 1. Get authorization URL
curl -H "Authorization: Bearer <token>" \
  http://localhost:3000/api/v1/calendar/google/connect

# 2. Visit URL in browser, authorize, and complete callback
```

**Test Digest Worker:**
```bash
# Run digest for specific user and date
rails calendar:test_digest[1,"2025-11-25"]
```

**Test Event Fetching:**
```ruby
# Rails console
user = User.first
account = user.calendar_accounts.first
events = CalendarEventsFetcher.fetch_for_day(
  calendar_account: account,
  date: Date.today,
  tz: user.timezone
)
```

### Automated Tests

Run the test suite:
```bash
rspec spec/workers/daily_calendar_digest_worker_spec.rb
rspec spec/controllers/api/v1/calendar_controller_spec.rb
rspec spec/services/calendar_events_fetcher_spec.rb
```

## Monitoring

### Logs

Important log events:
- Calendar account creation/update
- Digest enqueuing
- Event fetching (with counts)
- Token refresh attempts
- Errors with full context

### Metrics to Monitor

- Daily digest jobs enqueued
- Daily digest jobs succeeded/failed
- Token refresh success rate
- Active calendar accounts per provider
- Average events per user
- Notification delivery success rate

## Troubleshooting

### No digests being sent

1. **Check cron is running:**
   ```bash
   crontab -l
   # or check sidekiq-cron dashboard
   ```

2. **Check user has active calendar accounts:**
   ```ruby
   user = User.find(user_id)
   user.calendar_accounts.active.count # Should be > 0
   ```

3. **Verify timezone and digest_hour:**
   ```ruby
   user.timezone # e.g., "America/New_York"
   user.digest_hour # e.g., 8
   ```

4. **Check Sidekiq is running:**
   ```bash
   ps aux | grep sidekiq
   ```

### OAuth callback fails

1. **Verify redirect URIs match exactly:**
   - Google Console: `http://localhost:3000/api/v1/calendar/google/callback`
   - Azure Portal: `http://localhost:3000/api/v1/calendar/microsoft/callback`

2. **Check environment variables:**
   ```bash
   echo $GOOGLE_CLIENT_ID
   echo $GOOGLE_CLIENT_SECRET
   ```

3. **Enable debug logging:**
   ```ruby
   Rails.logger.level = :debug
   ```

### Token refresh fails

1. **Check refresh_token is present:**
   ```ruby
   account.refresh_token.present?
   ```

2. **Verify OAuth was configured with offline_access:**
   - Google: `access_type=offline&prompt=consent`
   - Microsoft: `offline_access` scope

3. **Re-connect the calendar** if refresh_token is invalid

## Production Deployment

### Pre-deployment Checklist

- [ ] Set strong JWT_SECRET_KEY
- [ ] Configure production OAuth credentials
- [ ] Set correct FRONTEND_URL
- [ ] Enable Rails encryption (set RAILS_MASTER_KEY)
- [ ] Configure Sidekiq with Redis
- [ ] Set up cron job for digest enqueuer
- [ ] Configure log aggregation
- [ ] Set up monitoring alerts
- [ ] Test OAuth flow in production environment
- [ ] Verify SSL/HTTPS for all OAuth redirects

### Scaling Considerations

For high user volumes:
- Use Redis-based deduplication for digest jobs
- Implement rate limiting per calendar provider
- Add retry queues with different priorities
- Cache frequently accessed calendar data
- Monitor API quotas for Google/Microsoft

## API Rate Limits

### Google Calendar API
- Default: 1,000,000 queries/day
- Per-user limit: 500 queries/100 seconds

### Microsoft Graph API
- Application: 10,000 requests/10 minutes
- Per-user: Varies by subscription

## Support

For issues or questions:
1. Check logs: `tail -f log/production.log`
2. Review Sidekiq dashboard: `/sidekiq`
3. Verify OAuth configurations in respective consoles
4. Test manually with rake task
