class SendNotificationsForNewQuestionJob
  @queue = :new_question_notifications

  def self.perform(question_id)
    debugger
    question = Question.find(question_id)

    question.league.users.where("users.wants_notifications = ? and users.wants_new_question_notifications = ?", true, true).each do |user|      
      user.device_tokens.each do |token|
        notification = Grocer::Notification.new(
          device_token: token.value,
          alert:        "The question \"#{question.content}\" was published in #{question.league.name}",
          badge:        1,
          expiry:       1.day.from_now
        )

        pusher.push(notification)
      end
    end

  end

end