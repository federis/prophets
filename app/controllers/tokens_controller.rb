class TokensController < ApplicationController
  prepend_before_filter :allow_params_authentication!, :only => :create
  skip_authorization_check :only => [:create, :facebook]
  skip_before_filter :authenticate_user!, :only => :facebook

  def create
    current_user.ensure_authentication_token!
    @user = current_user
    render "user_with_token"
  end

  def facebook
    facebook = Koala::Facebook::API.new(params[:fb_token])
    me = facebook.get_object("me")
    debugger
    if !me.nil?
      @user = User.from_facebook(me)
      if @user
        render "user_with_token"
      else

      end
    else
      render_unauthenticated
    end

  rescue Koala::Facebook::APIError => error
    render_unauthenticated
  end


private

  def render_unauthenticated
    render :json => { :error =>  I18n.t('devise.failure.unauthenticated') }, :status => :unauthorized
  end

end