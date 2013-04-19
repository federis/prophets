module FFP
  module PushNotifications
    extend self

    SEND_NEW_QUESTION_NOTIFICATIONS = true
    SEND_NEW_COMMENT_NOTIFICATIONS = false
    SEND_QUESTION_CREATED_NOTIFICATIONS = false

    def grocer
      @grocer ||= begin
                    connection = Grocer::PushConnection.new(certificate: cert_location)
                    connection.connect
                    Grocer::Pusher.new(connection)
                  end
    end

    def cert_location
      if Rails.env.production? 
        "/var/www/apps/prophets/ProphetsProdPushNotificationCertificate.pem"
      else
        "#{Rails.root}/lib/ios_push_cert_dev.pem" 
      end
    end
  end
end