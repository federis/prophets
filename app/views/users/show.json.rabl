object @user
attributes :id, :email, :name, :fb_uid, :fb_token, :fb_token_expires_at, :created_at, :updated_at
attributes :wants_notifications, :wants_new_question_notifications, :wants_new_comment_notifications, :wants_question_created_notifications
attributes :authentication_token if @include_auth_token