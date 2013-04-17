class SendNotificationsForCreatedQuestionJob
  @queue = :question_created_notifications

  def self.perform(question_id)
    Rails.logger.info "Starting APNs for created question #{question_id}"
    
    question = Question.find(question_id)

    #these only go to admins, since they need to approve questions. Normal users can't see questions until they are approved.
    question.league.admins.where("users.wants_notifications = ? and users.wants_question_created_notifications = ?", true, true).each do |user|
      unless question.user_id == user.id
        user.device_tokens.each do |token|
          notification = Grocer::Notification.new(
            device_token: token.value,
            alert:        "#{question.user.name} created the question \"#{question.content}\" in #{question.league.name}",
            badge:        1,
            expiry:       1.day.from_now,
            custom: { 
              "notificationType" => "questionCreated",
              "leagueId" => question.league_id,
              "questionId" => question.id 
            }
          )
          
          Rails.logger.info "Sending created question #{question.id} notification to user #{user.id}"
          
          ret = FFP::PushNotifications.grocer.push(notification)
        end
      end
    end

  end

end