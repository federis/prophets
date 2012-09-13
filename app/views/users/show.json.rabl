object @user
attributes :id, :email, :name, :created_at, :updated_at
attributes :authentication_token if @include_auth_token