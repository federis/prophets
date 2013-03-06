module FFP
  module PushNotifications
    extend self

    def grocer
      @grocer ||= begin
                    cert_location = Rails.env.production? ? "" : "#{Rails.root}/lib/ios_push_cert_dev.pem" 
                    connection = Grocer::PushConnection.new(certificate: cert_location)
                    connection.connect
                    Grocer::Pusher.new(connection)
                  end
    end
  end
end