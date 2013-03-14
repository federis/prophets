set :output, "#{Rails.root}/log/cron.log"

every 6.hours do
    rake "device_tokens:delete_tokens_from_feedback_service"
end