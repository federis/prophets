set :output, "log/cron.log"

every 5.minutes do
  rake "device_tokens:delete_tokens_from_feedback_service"
end