object @user
attributes :id, :email, :name, :created_at, :updated_at
attributes :fb_uid, :fb_token, :fb_token_expires_at, :publish_bets_to_fb, :publish_created_leagues_to_fb
attributes :wants_notifications, :wants_new_question_notifications, :wants_new_comment_notifications, :wants_question_created_notifications
attributes :authentication_token if @include_auth_token