# Calendar Integration - Quick Reference

## 🚀 Quick Start

### 1. Environment Setup (5 minutes)

```bash
# Add to .env
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
MICROSOFT_CLIENT_ID=your_client_id
MICROSOFT_CLIENT_SECRET=your_client_secret
FRONTEND_URL=http://localhost:3001

# Run migrations
rails db:migrate

# Start Sidekiq
bundle exec sidekiq
```

### 2. Cron Setup (1 minute)

```bash
# Add to crontab
*/15 * * * * cd /path/to/app && bin/rails calendar:enqueue_daily_digests RAILS_ENV=production
```

## 📡 API Endpoints

### Connect Calendar
```bash
GET /api/v1/calendar/google/connect
GET /api/v1/calendar/microsoft/connect
Authorization: Bearer <token>

Response: { "authorization_url": "https://..." }
```

### OAuth Callback (automatic)
```bash
GET /api/v1/calendar/:provider/callback?code=xxx&state=xxx
→ Redirects to: {FRONTEND_URL}/calendar/connected?provider=google&status=success
```

## 🧪 Testing Commands

```bash
# Test digest for user
rails calendar:test_digest[1,"2025-11-25"]

# Manually enqueue digest
rails runner "DailyCalendarDigestWorker.perform_async(1, '2025-11-25')"

# Check calendar accounts
rails console
User.first.calendar_accounts.active

# Check notifications
User.first.notifications.unread

# Test event fetching
account = CalendarAccount.first
CalendarEventsFetcher.fetch_for_day(
  calendar_account: account,
  date: Date.today,
  tz: 'America/New_York'
)
```

## 🔧 Common Tasks

### Check User's Calendar Setup
```ruby
user = User.find(user_id)
puts "Timezone: #{user.timezone}"
puts "Digest Hour: #{user.digest_hour}"
puts "Active Calendars: #{user.calendar_accounts.active.count}"
user.calendar_accounts.each do |account|
  puts "  - #{account.provider}: #{account.email} (expires: #{account.expires_at})"
end
```

### Force Token Refresh
```ruby
account = CalendarAccount.find(id)
account.refresh_access_token!
```

### Send Test Notification
```ruby
user = User.first
AppNotificationService.notify(
  user: user,
  title: "Test Notification",
  body: "This is a test",
  data: { type: 'test' }
)
```

### Check Digest Schedule
```ruby
# Find users who should receive digest now
now = Time.current
User.find_each do |user|
  tz = ActiveSupport::TimeZone[user.timezone]
  local_time = tz.now
  if local_time.hour == user.digest_hour
    puts "#{user.email} should receive digest (local time: #{local_time})"
  end
end
```

## 🐛 Debugging

### Check Logs
```bash
# Calendar-specific logs
tail -f log/development.log | grep -i calendar

# Sidekiq logs
tail -f log/sidekiq.log
```

### Common Issues

**No digest received:**
- Check cron is running: `crontab -l`
- Verify user has active calendar accounts
- Check user's timezone and digest_hour
- Ensure Sidekiq is running

**OAuth fails:**
- Verify redirect URIs match exactly
- Check client ID and secret are correct
- Ensure scopes are configured properly

**Token expired:**
- Account automatically marked inactive
- User receives reconnection notification
- User needs to reconnect via OAuth flow

## 📊 Monitoring Queries

```ruby
# Active calendar accounts by provider
CalendarAccount.active.group(:provider).count

# Users with calendars connected
User.joins(:calendar_accounts).where(calendar_accounts: { active: true }).distinct.count

# Recent notifications
Notification.where('created_at > ?', 1.day.ago).count

# Failed jobs
Sidekiq::DeadSet.new.size
```

## 🔐 OAuth Provider URLs

**Google Console:** https://console.cloud.google.com/apis/credentials
**Azure Portal:** https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps

## 📝 Key Files

```
Models:
  app/models/calendar_account.rb
  app/models/notification.rb
  app/models/user.rb

Services:
  app/services/calendar_account_creator.rb
  app/services/calendar_events_fetcher.rb
  app/services/app_notification_service.rb

Workers:
  app/jobs/daily_calendar_digest_worker.rb

Controllers:
  app/controllers/api/v1/calendar_controller.rb

Tasks:
  lib/tasks/calendar.rake

Migrations:
  db/migrate/*_create_calendar_accounts.rb
  db/migrate/*_add_calendar_fields_to_users.rb
  db/migrate/*_create_notifications.rb
```

## 🎯 Production Checklist

- [ ] OAuth credentials configured in production
- [ ] RAILS_MASTER_KEY set for token encryption
- [ ] Cron job scheduled (every 15 minutes)
- [ ] Sidekiq running and monitored
- [ ] Redis configured for Sidekiq
- [ ] Log aggregation set up
- [ ] FRONTEND_URL points to production domain
- [ ] SSL/HTTPS enabled for OAuth redirects
- [ ] Rate limiting monitoring in place
- [ ] Error alerting configured

## 💡 Tips

1. **Test locally first** - Use `rails calendar:test_digest` before deploying
2. **Monitor token refresh** - Watch for accounts marked inactive
3. **Rate limits** - Be aware of Google/Microsoft API quotas
4. **Timezone testing** - Test with users in different timezones
5. **Error handling** - Check Sidekiq dead queue regularly

## 🆘 Emergency Commands

```bash
# Pause digest processing
# (Stop cron or comment out cron job)

# Retry failed jobs
rails runner "Sidekiq::RetrySet.new.retry_all"

# Clear dead jobs
rails runner "Sidekiq::DeadSet.new.clear"

# Disable all calendar accounts
rails runner "CalendarAccount.update_all(active: false)"

# Re-enable specific account
rails runner "CalendarAccount.find(ID).update(active: true)"
```

## 📞 Support

See full documentation:
- `CALENDAR_INTEGRATION_README.md` - Complete setup guide
- `CALENDAR_IMPLEMENTATION_SUMMARY.md` - Implementation details
- Swagger UI: http://localhost:3000/api-docs
