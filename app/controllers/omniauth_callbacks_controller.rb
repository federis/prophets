class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    user = User.from_facebook(request.env["omniauth.auth"], :omniauth)
    
    if user.persisted?
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url(:fb => true)
    end
  end
end