class AppNotificationService
  class << self
    def notify(user:, title:, body:, data: {})
      new(user:, title:, body:, data:).call
    end
  end

  def initialize(user:, title:, body:, data: {})
    @user = user
    @title = title
    @body = body
    @data = data
  end

  def call
    notification = @user.notifications.create!(
      title: @title,
      body: @body,
      data: @data
    )

    Rails.logger.info("Notification created: user_id=#{@user.id}, title=#{@title}")

    # Here you could also trigger push notifications, websockets, etc.
    # broadcast_notification(notification)

    notification
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to create notification: #{e.message}")
    raise
  end

  private

  # Placeholder for future real-time notification delivery
  def broadcast_notification(notification)
    # ActionCable.server.broadcast(
    #   "notifications_#{@user.id}",
    #   notification: notification.as_json
    # )
  end
end
