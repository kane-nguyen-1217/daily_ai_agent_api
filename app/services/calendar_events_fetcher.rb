class CalendarEventsFetcher
  class << self
    def fetch_for_day(calendar_account:, date:, tz:)
      new(calendar_account:, date:, tz:).fetch
    end
  end

  def initialize(calendar_account:, date:, tz:)
    @calendar_account = calendar_account
    @date = date
    @tz = ActiveSupport::TimeZone[tz] || ActiveSupport::TimeZone['UTC']
  end

  def fetch
    # Ensure we have a valid access token
    @calendar_account.ensure_access_token!

    case @calendar_account.provider
    when 'google'
      fetch_google_events
    when 'microsoft'
      fetch_microsoft_events
    else
      raise "Unsupported provider: #{@calendar_account.provider}"
    end
  rescue StandardError => e
    Rails.logger.error("Failed to fetch events for CalendarAccount##{@calendar_account.id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))

    # If it's a 429 rate limit, just return empty and let Sidekiq retry
    if e.message.include?('429') || e.message.include?('rate limit')
      Rails.logger.warn("Rate limit hit for CalendarAccount##{@calendar_account.id}, will retry")
      raise # Let Sidekiq handle the retry
    end

    []
  end

  private

  def day_start_utc
    @day_start_utc ||= @tz.local_to_utc(@tz.parse(@date.to_s).beginning_of_day)
  end

  def day_end_utc
    @day_end_utc ||= @tz.local_to_utc(@tz.parse(@date.to_s).end_of_day)
  end

  def fetch_google_events
    require 'net/http'
    require 'json'
    require 'uri'

    uri = URI('https://www.googleapis.com/calendar/v3/calendars/primary/events')
    uri.query = URI.encode_www_form({
                                      timeMin: day_start_utc.iso8601,
                                      timeMax: day_end_utc.iso8601,
                                      singleEvents: true,
                                      orderBy: 'startTime',
                                      maxResults: 100
                                    })

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{@calendar_account.access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code == '200'
      result = JSON.parse(response.body)
      normalize_google_events(result['items'] || [])
    elsif response.code == '429'
      raise 'Google Calendar API rate limit exceeded'
    else
      raise "Google Calendar API error: #{response.code} - #{response.body}"
    end
  end

  def normalize_google_events(events)
    events.map do |event|
      {
        provider: 'google',
        provider_event_id: event['id'],
        title: event['summary'] || '(No title)',
        start_at: parse_google_datetime(event['start']),
        end_at: parse_google_datetime(event['end']),
        all_day: event['start']['date'].present?,
        organizer_email: event['organizer']&.dig('email'),
        raw: event
      }
    end
  end

  def parse_google_datetime(datetime_obj)
    if datetime_obj['dateTime']
      Time.parse(datetime_obj['dateTime'])
    elsif datetime_obj['date']
      Date.parse(datetime_obj['date']).to_time
    else
      Time.current
    end
  end

  def fetch_microsoft_events
    require 'net/http'
    require 'json'
    require 'uri'

    uri = URI('https://graph.microsoft.com/v1.0/me/calendar/calendarView')
    uri.query = URI.encode_www_form({
                                      startDateTime: day_start_utc.iso8601,
                                      endDateTime: day_end_utc.iso8601,
                                      '$orderby' => 'start/dateTime',
                                      '$top' => 100
                                    })

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{@calendar_account.access_token}"
    request['Prefer'] = 'outlook.timezone="UTC"'

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code == '200'
      result = JSON.parse(response.body)
      normalize_microsoft_events(result['value'] || [])
    elsif response.code == '429'
      raise 'Microsoft Graph API rate limit exceeded'
    else
      raise "Microsoft Graph API error: #{response.code} - #{response.body}"
    end
  end

  def normalize_microsoft_events(events)
    events.map do |event|
      {
        provider: 'microsoft',
        provider_event_id: event['id'],
        title: event['subject'] || '(No title)',
        start_at: Time.parse(event['start']['dateTime']),
        end_at: Time.parse(event['end']['dateTime']),
        all_day: event['isAllDay'] == true,
        organizer_email: event['organizer']&.dig('emailAddress', 'address'),
        raw: event
      }
    end
  end
end
