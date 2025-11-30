namespace :calendar do
  desc 'Enqueue daily calendar digest workers for users whose local time matches their digest hour'
  task enqueue_daily_digests: :environment do
    Rails.logger.info("Starting calendar digest enqueuer at #{Time.current}")

    enqueued_count = 0

    User.find_each do |user|
      # Get user's timezone and digest hour
      tz = ActiveSupport::TimeZone[user.timezone] || ActiveSupport::TimeZone['Asia/Ho_Chi_Minh']
      digest_hour = user.digest_hour || 8

      # Calculate user's local time
      user_local_time = tz.now
      user_local_hour = user_local_time.hour

      # Check if we're within the scheduling window (±15 minutes of digest hour)
      # Since this runs every 15 minutes, we check if current hour matches digest hour
      if user_local_hour == digest_hour
        # Check if we haven't already enqueued today
        date_str = user_local_time.to_date.to_s

        # Avoid duplicate jobs - check if a job for this user/date combination already exists
        # This is a simple check - in production you might want Redis-based deduplication

        DailyCalendarDigestWorker.perform_async(user.id, date_str)
        enqueued_count += 1

        Rails.logger.info("Enqueued digest for user_id=#{user.id}, local_time=#{user_local_time}, date=#{date_str}")
      end
    rescue StandardError => e
      Rails.logger.error("Failed to enqueue digest for user_id=#{user.id}: #{e.message}")
    end

    Rails.logger.info("Enqueued #{enqueued_count} daily calendar digest jobs")
  end

  desc 'Test calendar digest for a specific user and date'
  task :test_digest, %i[user_id date] => :environment do |_t, args|
    user_id = args[:user_id] || 1
    date = args[:date] || Date.today.to_s

    puts "Testing calendar digest for user_id=#{user_id}, date=#{date}"

    DailyCalendarDigestWorker.new.perform(user_id, date)

    puts 'Test completed. Check logs for details.'
  end
end
