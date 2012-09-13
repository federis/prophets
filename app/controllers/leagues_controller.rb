class LeaguesController < ApplicationController
  authorize_resource :except => [:create]

  self.responder = ApiResponder
  respond_to :json
  respond_to :html, :only => :index

  def index
    @leagues = current_user.leagues
    respond_with @leagues
  end

  def create
    @league = current_user.created_leagues.build(params[:league])
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

private

  def current_league
    @league ||= League.find(params[:id]) unless params[:id].nil?
  end

end
