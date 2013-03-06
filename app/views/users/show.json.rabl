object @user
attributes :id, :email, :name, :wants_notifications, :wants_new_question_notifications, :created_at, :updated_at
attributes :authentication_token if @include_auth_token