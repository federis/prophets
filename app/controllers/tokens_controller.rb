class TokensController < ApplicationController
  prepend_before_filter :allow_params_authentication!, :only => :create
  skip_authorization_check :only => [:create, :facebook, :facebook_for_existing_user]
  skip_before_filter :authenticate_user!, :only => :facebook

  self.responder = ApiResponder
  respond_to :json

  def create
    current_user.ensure_authentication_token!
    @user = current_user
    @include_auth_token = true
    respond_with @user, :location => nil
  end

  def facebook
    facebook = Koala::Facebook::API.new(params[:fb_token])
    me = facebook.get_object("me")
    @user = User.where(:fb_uid => me['id']).first
    if @user
      @user.update_attributes(fb_token: facebook.access_token, fb_token_expires_at: params[:fb_token_expires_at], fb_token_refreshed_at: params[:fb_token_refreshed_at])
      @include_auth_token = true
      respond_with @user, :location => nil
    else
      render :json => { :error => I18n.t('tokens.fb_user_not_found') }, :status => :not_found
    end
    
  rescue Koala::Facebook::APIError => error
    render :json => { :error => error.fb_error_message }, :status => :unauthorized
  end

end