namespace :device_tokens do
  task :delete_tokens_from_feedback_service => :environment do
    puts "[#{Time.now}] Beginning check of APNS feedback service"

    feedback = Grocer.feedback(certificate: FFP::PushNotifications.cert_location)
    feedback.each do |attempt|
      DeviceToken.where(value: attempt.device_token.upcase).each do |token|
        if attempt.timestamp > token.updated_at
          puts "Destroying device token #{token.id} - #{token.value}"
          token.destroy 
        else
          puts "Skipped destroying device token #{token.id} - #{token.value} due to recent update"
        end
      end
    end

    puts "[#{Time.now}] Finished processing tokens from APNS feedback service"
  end
end