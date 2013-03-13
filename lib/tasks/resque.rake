require 'resque/tasks'

task "resque:setup" => :environment do
  FFP::PushNotifications.grocer #accessing grocer causes the connection to be made to APNS

  logger = Logger.new("#{Rails.root}/log/resque.log")
  logger.formatter = Proc.new{|severity, datetime, progname, msg| "[#{Time.now}] [#{severity}] #{msg}\n"}
  ActiveRecord::Base.logger = logger
  Rails.logger = logger
  
  Resque.before_fork = Proc.new do
    ActiveRecord::Base.establish_connection
  end
end