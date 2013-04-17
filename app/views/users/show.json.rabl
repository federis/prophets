object @user
attributes :id, :email, :name, :created_at, :updated_at
attributes :wants_notifications, :wants_new_question_notifications, :wants_new_comment_notifications, :wants_question_created_notifications
attributes :authentication_token if @include_auth_token