namespace :device_tokens do
  task :delete_tokens_from_feedback_service => :environment do
    Rails.logger.info "[#{Time.now}] Beginning check of APNS feedback service"

    feedback = Grocer.feedback(certificate: FFP::PushNotifications.cert_location)
    feedback.each do |attempt|
      DeviceToken.where(value: attempt.device_token.upcase).each do |token|
        if attempt.timestamp > token.updated_at
          Rails.logger.info "Destroying device token #{token.id} - #{token.value}"
          token.destroy 
        else
          Rails.logger.info "Skipped destroying device token #{token.id} - #{token.value} due to recent update"
        end
      end
    end

    Rails.logger.info "[#{Time.now}] Finished processing tokens from APNS feedback service"
  end
end