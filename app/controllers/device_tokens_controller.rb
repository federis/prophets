class DeviceTokensController < ApplicationController
  skip_authorization_check only: :create

  respond_to :json

  def create
    #do it this way so that if someone else signs into a device that already has a token, we will just replace the user
    #associated with that token instead of having 2 tokens for the same device but diff users
    @device_token = DeviceToken.find_or_initialize_by_value(params[:device_token][:value])
    @device_token.user = current_user
    @device_token.save
    respond_with @device_token, location: nil
  end
end
