class TokensController < ApplicationController
  prepend_before_filter :allow_params_authentication!, :only => :create
  skip_authorization_check :only => :create

  def create
    current_user.ensure_authentication_token!
    @user = current_user
    render "user_with_token"
  end

end