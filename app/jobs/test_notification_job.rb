class TestNotificationJob
  @queue = :test_notifications

  def self.perform(user_id, note_text)
    Rails.logger.info "Starting APNs for test notification user #{user_id}"
    
    user = User.find(user_id)

    user.device_tokens.each do |token|
      notification = Grocer::Notification.new(
        device_token: token.value,
        alert:        note_text,
        badge:        1,
        expiry:       1.day.from_now,
        custom: { 
          "notificationType" => "testNotification",
          "userId" => user.id
        }
      )
      
      Rails.logger.info "Sending test notification \"#{note_text}\" notification to user #{user.id} at token #{token.value}"
      
      ret = FFP::PushNotifications.grocer.push(notification)
      Rails.logger.info "Return value was #{ret}"
    end

  end

end