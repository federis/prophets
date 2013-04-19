class SendNotificationsForNewQuestionJob
  @queue = :new_question_notifications

  def self.perform(question_id)
    unless FFP::PushNotifications::SEND_NEW_QUESTION_NOTIFICATIONS
      Rails.logger.info "New question notifications are turned off. Skipping notifications."
      return
    end

    Rails.logger.info "Starting APNs for new question #{question_id}"
    
    question = Question.find(question_id)

    question.league.users.where("users.wants_notifications = ? and users.wants_new_question_notifications = ?", true, true).each do |user|      
      user.device_tokens.each do |token|
        notification = Grocer::Notification.new(
          device_token: token.value,
          alert:        "The question \"#{question.content}\" was published in #{question.league.name}",
          badge:        1,
          expiry:       1.day.from_now,
          custom: { 
            "notificationType" => "newQuestion",
            "leagueId" => question.league_id,
            "questionId" => question.id 
          }
        )
        
        Rails.logger.info "Sending new question #{question.id} notification to user #{user.id}"
        
        ret = FFP::PushNotifications.grocer.push(notification)
        
        Rails.logger.info "Return value was #{ret}"
      end
    end

  end

end