class RegistrationsController < Devise::RegistrationsController

  REGISTRATION_SECRET = "7eaeaff73a42ececa4392fd99000d5f9cfa76b41"

  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :verify_authentic_request, :only => :create

  def new    
    @fb_registration = params[:fb] == "true" && session['devise.user_attributes']
    session.delete('devise.user_attributes') unless @fb_registration 
    super
  end
  
private

  def verify_authentic_request
    if request.format == "application/json"
      raise unless params[:registration_secret] == REGISTRATION_SECRET
    else
      verify_authenticity_token
    end    
  end
end