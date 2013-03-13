class DeviceTokensController < ApplicationController
  skip_authorization_check only: :create

  respond_to :json

  def create
    #do it this way so that if someone else signs into a device that already has a token, we will just replace the user
    #associated with that token instead of having 2 tokens for the same device but diff users
    
    @device_token = DeviceToken.find_or_initialize_by_value(params[:device_token][:value])
    if @device_token.user_id != current_user.id
      @device_token.user = current_user
      @device_token.save
    end
    respond_with @device_token, location: nil
  end
end
