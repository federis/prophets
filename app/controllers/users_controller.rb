class UsersController < ApplicationController
  respond_to :json

  def show
    @user = User.find(params[:id])
    
    authorize! :show, @user
    respond_with @user, :location => nil
  end

  #for connecting a facebook account to an existing user
  def facebook
    authorize! :connect_facebook, current_user
    facebook = Koala::Facebook::API.new(params[:fb_token])
    me = facebook.get_object("me")
    
    @user = current_user
    @user.update_attributes(fb_uid: me['id'], fb_token: facebook.access_token, fb_token_expires_at: params[:fb_token_expires_at], fb_token_refreshed_at: params[:fb_token_refreshed_at])
    @include_auth_token = true
    respond_with @user, :location => nil
    
  rescue Koala::Facebook::APIError => error
    render :json => { :error => error.fb_error_message }, :status => :unauthorized
  end

end