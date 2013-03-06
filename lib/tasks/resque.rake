require 'resque/tasks'

task "resque:setup" => :environment do
  FFP::PushNotifications.grocer #accessing grocer causes the connection to be made to APNS

  Resque.before_fork = Proc.new do
    ActiveRecord::Base.establish_connection
  end
end