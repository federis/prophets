class SendNotificationsForNewCommentJob
  @queue = :new_comment_notifications

  def self.perform(comment_id)
    unless FFP::PushNotifications::SEND_NEW_COMMENT_NOTIFICATIONS
      Rails.logger.info "New comment notifications are turned off. Skipping notifications."
      return
    end

    Rails.logger.info "Starting APNs for new comment #{comment_id}"
    
    comment = Comment.find(comment_id)

    league = if comment.commentable.is_a?(League)
      comment.commentable
    elsif comment.commentable.is_a?(Question)
      comment.commentable.league
    elsif comment.commentable.is_a?(Bet)
      comment.commentable.answer.question.league
    end

    if league.nil?
      Rails.logger.info "Commentable was not a League, Question, or Bet. Skipping notifications"
      return
    end

    league.users.where("users.wants_notifications = ? and users.wants_new_comment_notifications = ?", true, true).each do |user|
      unless user.id == comment.user_id
        user.device_tokens.each do |token|
          notification = Grocer::Notification.new(
            device_token: token.value,
            alert:        "#{comment.user.name} said: \"#{comment.comment}\"",
            badge:        1,
            expiry:       1.day.from_now,
            custom: { 
              "notificationType" => "newComment",
              "leagueId" => league.id,
              "commentableType" => comment.commentable_type,
              "commentableId" => comment.commentable_id 
            }
          )
          
          Rails.logger.info "Sending new comment #{comment.id} notification to user #{user.id}"
          
          ret = FFP::PushNotifications.grocer.push(notification)
        end
      end
    end

  end

end