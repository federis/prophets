class SendNotificationsForJudgementJob
  @queue = :judgement_notifications

  def self.perform(answer_id, was_correct)
    unless FFP::PushNotifications::SEND_JUDGEMENT_NOTIFICATIONS
      Rails.logger.info "Judgement notifications are turned off. Skipping notifications."
      return
    end

    Rails.logger.info "Starting APNs for judgement of #{answer_id}"
    
    answer = Answer.find(answer_id)

    answer.bets.includes(:membership => :user).each do |bet|
      user = bet.membership.user
      if user.wants_notifications && user.wants_judgement_notifications
      
        user.device_tokens.each do |token|
          won_or_lost = was_correct ? "won" : "lost"
          value = was_correct ? bet.payout : bet.amount
          
          notification = Grocer::Notification.new(
            device_token: token.value,
            alert:        "You #{won_or_lost} #{ActionController::Base.helpers.number_to_currency(value)} in the question \"#{answer.question.content}\"",
            badge:        1,
            expiry:       1.day.from_now,
            custom: { 
              "notificationType" => "judgement",
              "leagueId" => answer.question.league_id,
              "questionId" => answer.question_id
            }
          )
          Rails.logger.info "Sending answer #{answer.id} judgement notification to user #{user.id}"
          
          ret = FFP::PushNotifications.grocer.push(notification)
          
          Rails.logger.info "Return value was #{ret}"
        end

      end
    end

  end

end