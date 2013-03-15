set :output, "log/cron.log"

every 3.hours do
  rake "device_tokens:delete_tokens_from_feedback_service"
end