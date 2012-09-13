class RegistrationsController < Devise::RegistrationsController

  REGISTRATION_SECRET = "7eaeaff73a42ececa4392fd99000d5f9cfa76b41"

  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :verify_authentic_request, :only => :create
  before_filter :verify_facebook_token, :only => :create
  before_filter :cleanup_omniauth_attributes, :only => :new

  self.responder = ApiResponder
  respond_to :json
  
private

  def verify_authentic_request
    if request.format == "application/json"
      raise unless params[:registration_secret] == REGISTRATION_SECRET
      @include_auth_token = true
    else
      verify_authenticity_token
    end
  end

  def verify_facebook_token
    if params[:user][:fb_token]
      begin
        facebook = Koala::Facebook::API.new(params[:user][:fb_token])
        me = facebook.get_object("me")
        params[:user][:fb_uid] = me.id
      rescue Koala::Facebook::APIError => error
        render :json => {:errors => { :fb_token => "is invalid" }}, :status => :unprocessable_entity
      end
    end
  end

  def cleanup_omniauth_attributes
    @fb_registration = params[:fb] == "true" && session['devise.user_attributes']
    session.delete('devise.user_attributes') unless @fb_registration 
  end
end