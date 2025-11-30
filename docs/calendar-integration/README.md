# Calendar Integration Documentation

Complete documentation for Google Calendar and Microsoft Outlook integration functionality.

## 📅 Overview

The calendar integration feature provides:
- **Google Calendar** integration via OAuth 2.0
- **Microsoft Outlook/Office 365** integration 
- **Automated daily digest** delivery
- **Timezone-aware** scheduling
- **Secure token management** with encryption

## 📁 Files in this section

### [`CALENDAR_INTEGRATION_README.md`](CALENDAR_INTEGRATION_README.md)
Complete setup guide including:
- **Prerequisites** - OAuth app configuration
- **Environment setup** - Required environment variables
- **OAuth flow** - Step-by-step authentication process
- **Testing** - How to test calendar connections

### [`CALENDAR_IMPLEMENTATION_SUMMARY.md`](CALENDAR_IMPLEMENTATION_SUMMARY.md)
Technical implementation details:
- **Database models** - CalendarAccount, Notification models
- **Services** - CalendarEventsFetcher, CalendarAccountCreator
- **Background jobs** - DailyCalendarDigestWorker
- **Controllers** - OAuth endpoints and callbacks

### [`CALENDAR_QUICK_REFERENCE.md`](CALENDAR_QUICK_REFERENCE.md)
Quick commands and testing:
- **Testing commands** - Rails console commands for testing
- **API endpoints** - Calendar-specific API calls
- **Debugging** - Common issues and solutions
- **Monitoring** - Queries for checking system health

## 🚀 Quick Start

### 1. **Setup OAuth Apps**
- **Google**: https://console.cloud.google.com/apis/credentials
- **Microsoft**: https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps

### 2. **Configure Environment**
```bash
# Add to .env
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
MICROSOFT_CLIENT_ID=your_client_id
MICROSOFT_CLIENT_SECRET=your_client_secret
FRONTEND_URL=http://localhost:3001
```

### 3. **Test Connection**
```bash
# Test calendar digest
rails calendar:test_digest[1,"2025-11-30"]

# Check connections
rails console
User.first.calendar_accounts.active
```

## 🔗 API Endpoints

### **OAuth Initiation**
- `GET /api/v1/calendar/google/connect` - Start Google OAuth
- `GET /api/v1/calendar/microsoft/connect` - Start Microsoft OAuth

### **OAuth Callbacks** (automatic)
- `GET /api/v1/calendar/:provider/callback` - Handle OAuth response

### **Testing Endpoints**
```bash
# Get authorization URL
curl -H "Authorization: Bearer <token>" \
     http://localhost:3000/api/v1/calendar/google/connect
```

## 🗄️ Database Schema

### **calendar_accounts table**
```sql
id            - Primary key
user_id       - Foreign key to users
provider      - 'google' or 'microsoft'
email         - Calendar account email
access_token  - Encrypted OAuth access token
refresh_token - Encrypted OAuth refresh token
expires_at    - Token expiration
active        - Connection status
```

### **notifications table**
```sql
id       - Primary key
user_id  - Foreign key to users
title    - Notification headline
body     - Detailed message
data     - JSONB with calendar events
read_at  - Read timestamp
```

## 🔧 Background Jobs

### **DailyCalendarDigestWorker**
- Runs daily at user's preferred hour
- Fetches events from all connected calendars
- Sends formatted digest via notifications
- Handles token refresh and errors

### **Cron Schedule**
```bash
# Add to crontab for production
*/15 * * * * cd /path/to/app && bin/rails calendar:enqueue_daily_digests RAILS_ENV=production
```

## 🔐 Security Features

- **Token Encryption** - All OAuth tokens encrypted at rest
- **Automatic Refresh** - Tokens refreshed before expiration
- **Graceful Degradation** - Inactive accounts on token failure
- **User Notifications** - Alerts when reconnection needed

## 🧪 Testing & Debugging

### **Test Commands**
```bash
# Test specific user digest
rails calendar:test_digest[user_id,"date"]

# Manual worker execution
rails runner "DailyCalendarDigestWorker.perform_async(1, '2025-11-30')"

# Check calendar accounts
User.find(1).calendar_accounts.active
```

### **Common Issues**
- **OAuth fails**: Check redirect URIs match exactly
- **No events**: Verify user has active calendar accounts
- **Token expired**: Check account marked inactive, user notified

## 🔗 Related Documentation

- **[Database Schema](../database/)** - CalendarAccount and Notification models
- **[API Documentation](../api/)** - Complete API reference
- **[OAuth Integration](../oauth-integration/)** - General OAuth patterns

## 📊 Monitoring

```ruby
# Active accounts by provider
CalendarAccount.active.group(:provider).count

# Users with calendars
User.joins(:calendar_accounts).where(calendar_accounts: { active: true }).distinct.count

# Recent notifications
Notification.where('created_at > ?', 1.day.ago).count
```

For detailed implementation, see the individual documentation files in this folder.
