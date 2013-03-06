class UsersController < ApplicationController
  respond_to :json

  def show
    @user = User.find(params[:id])
    
    authorize! :show, @user
    respond_with @user, :location => nil
  end

end