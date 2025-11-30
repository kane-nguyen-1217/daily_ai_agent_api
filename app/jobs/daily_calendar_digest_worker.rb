class DailyCalendarDigestWorker
  include Sidekiq::Worker

  sidekiq_options queue: :calendar_digest, retry: 3, backtrace: true

  def perform(user_id, date_str)
    user = User.find(user_id)
    date = Date.parse(date_str)
    timezone = user.timezone || 'Asia/Ho_Chi_Minh'

    Rails.logger.info("Processing daily calendar digest for user_id=#{user_id}, date=#{date}, tz=#{timezone}")

    # Load all active calendar accounts
    calendar_accounts = user.calendar_accounts.active

    if calendar_accounts.empty?
      Rails.logger.info("No active calendar accounts for user_id=#{user_id}")
      return
    end

    # Fetch events from all accounts
    all_events = []
    calendar_accounts.each do |account|
      events = CalendarEventsFetcher.fetch_for_day(
        calendar_account: account,
        date:,
        tz: timezone
      )
      all_events.concat(events)
      Rails.logger.info("Fetched #{events.count} events from #{account.provider} for user_id=#{user_id}")
    rescue StandardError => e
      Rails.logger.error("Failed to fetch events from CalendarAccount##{account.id}: #{e.message}")

      # If token refresh failed, the account is already marked inactive
      # Continue with other accounts
      next
    end

    # If no events, optionally send a notification or skip
    if all_events.empty?
      Rails.logger.info("No events found for user_id=#{user_id} on #{date}")
      # Optionally notify user: "You have no events scheduled for today"
      return
    end

    # Sort events by start time
    all_events.sort_by! { |e| e[:start_at] }

    # Format notification
    title = "Your Calendar for #{format_date(date)}"
    body = format_events_summary(all_events)

    # Send notification
    AppNotificationService.notify(
      user:,
      title:,
      body:,
      data: {
        type: 'daily_calendar_digest',
        date: date.to_s,
        events_count: all_events.count,
        events: all_events.map { |e| format_event_data(e) }
      }
    )

    Rails.logger.info("Daily digest sent to user_id=#{user_id}, #{all_events.count} events")
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("User not found: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Error in DailyCalendarDigestWorker: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise # Let Sidekiq handle the retry
  end

  private

  def format_date(date)
    date.strftime('%A, %B %d, %Y')
  end

  def format_events_summary(events)
    return 'No events scheduled' if events.empty?

    summary = "You have #{events.count} event#{'s' if events.count > 1} today:\n\n"

    events.first(5).each do |event|
      time_str = if event[:all_day]
                   'All day'
                 else
                   event[:start_at].strftime('%I:%M %p')
                 end

      summary += "• #{time_str} - #{event[:title]}\n"
    end

    summary += "\n... and #{events.count - 5} more" if events.count > 5

    summary
  end

  def format_event_data(event)
    {
      provider: event[:provider],
      title: event[:title],
      start_at: event[:start_at].iso8601,
      end_at: event[:end_at].iso8601,
      all_day: event[:all_day],
      organizer_email: event[:organizer_email]
    }
  end
end
