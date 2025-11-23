# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create a demo user
demo_user = User.find_or_create_by!(email: 'demo@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.full_name = 'Demo User'
  user.timezone = 'UTC'
end

puts "Demo user created: #{demo_user.email}"

# Create sample automation settings
automation_types = ['calendar', 'email', 'crypto', 'summary', 'alert']
automation_types.each_with_index do |type, index|
  AutomationSetting.find_or_create_by!(
    user: demo_user,
    automation_type: type
  ) do |setting|
    setting.name = "#{type.capitalize} Automation"
    setting.configuration = {
      enabled: true,
      frequency: 'daily'
    }
    setting.priority = index
  end
end

puts "Created #{automation_types.count} automation settings"

# Create sample scheduler jobs
SchedulerJob.find_or_create_by!(
  user: demo_user,
  name: 'Daily Summary',
  job_type: 'daily_summary'
) do |job|
  job.schedule = '0 8 * * *'  # Every day at 8 AM
  job.job_parameters = { include_crypto: true, include_calendar: true }
  job.enabled = true
end

SchedulerJob.find_or_create_by!(
  user: demo_user,
  name: 'Crypto Price Check',
  job_type: 'crypto_check'
) do |job|
  job.schedule = '*/30 * * * *'  # Every 30 minutes
  job.job_parameters = { symbols: ['BTC', 'ETH', 'SOL'] }
  job.enabled = true
end

puts "Created sample scheduler jobs"

# Create sample crypto cache data
['BTC', 'ETH', 'SOL', 'ADA', 'DOT'].each do |symbol|
  CryptoDataCache.find_or_create_by!(symbol: symbol) do |cache|
    cache.price = rand(100.0..50000.0).round(2)
    cache.market_cap = rand(1_000_000_000..1_000_000_000_000)
    cache.volume_24h = rand(1_000_000..100_000_000)
    cache.change_24h = rand(-10.0..10.0).round(2)
    cache.change_7d = rand(-20.0..20.0).round(2)
    cache.cached_at = Time.current
  end
end

puts "Created sample crypto data"

# Create sample alerts
Alert.find_or_create_by!(
  user: demo_user,
  title: 'Welcome Alert'
) do |alert|
  alert.alert_type = 'custom'
  alert.message = 'Welcome to Daily AI Agent API!'
  alert.severity = 'info'
end

puts "Created sample alerts"

puts "\n✅ Database seeded successfully!"
puts "Demo user credentials:"
puts "  Email: demo@example.com"
puts "  Password: password123"
