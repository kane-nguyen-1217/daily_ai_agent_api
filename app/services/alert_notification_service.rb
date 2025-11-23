class AlertNotificationService
  # Service for sending alert notifications via various channels
  
  def self.send_alert(alert)
    user = alert.user
    
    # Send via Telegram if configured
    send_telegram_notification(alert, user) if user.telegram_links.verified.active.any?
    
    # Could also send via email, push notifications, etc.
    
    true
  end
  
  private
  
  def self.send_telegram_notification(alert, user)
    telegram_links = user.telegram_links.verified.active
    
    telegram_links.each do |link|
      send_telegram_message(
        chat_id: link.telegram_user_id,
        message: format_telegram_message(alert)
      )
    end
  rescue => e
    Rails.logger.error("Failed to send Telegram notification: #{e.message}")
  end
  
  def self.send_telegram_message(chat_id:, message:)
    bot_token = ENV['TELEGRAM_BOT_TOKEN']
    return unless bot_token
    
    HTTParty.post(
      "https://api.telegram.org/bot#{bot_token}/sendMessage",
      body: {
        chat_id: chat_id,
        text: message,
        parse_mode: 'Markdown'
      }
    )
  end
  
  def self.format_telegram_message(alert)
    severity_emoji = {
      'info' => 'ℹ️',
      'warning' => '⚠️',
      'critical' => '🚨'
    }
    
    <<~MESSAGE
      #{severity_emoji[alert.severity]} *#{alert.title}*
      
      #{alert.message}
      
      _#{alert.created_at.strftime('%Y-%m-%d %H:%M:%S')}_
    MESSAGE
  end
end
