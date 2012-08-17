class LeaguesController < ApplicationController
  load_and_authorize_resource :except => [:index, :create]

  self.responder = ApiResponder
  respond_to :json

  def index
    @leagues = current_user.leagues
    authorize! :index, League

    respond_with @leagues
  end

  def create
    @league = current_user.created_leagues.new(params[:league])
    authorize! :create, @league
    @league.save
    
    respond_with @league
  end

  def update
    @league.assign_attributes(params[:league])
    authorize! :update, @league
    @league.save
    respond_with @league
  end

end
