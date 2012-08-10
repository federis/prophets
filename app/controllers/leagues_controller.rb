class LeaguesController < ApplicationController
  self.responder = ApiResponder
  respond_to :json

  def create
    @league = current_user.created_leagues.new(params[:league])
    authorize! :create, @league
    @league.save
    
    respond_with @league
  end

end
