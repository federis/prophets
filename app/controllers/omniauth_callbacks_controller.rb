class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    user = User.find_or_create_omniauth_facebook_user(request.env["omniauth.auth"])
    
    if user.persisted?
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url(:fb => true)
    end
  end
end