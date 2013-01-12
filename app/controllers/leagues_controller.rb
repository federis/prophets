class LeaguesController < ApplicationController
  authorize_resource :except => [:create]

  self.responder = ApiResponder
  respond_to :json
  respond_to :html, :only => :index

  def index
    if params[:tag_id]
      @tag = ActsAsTaggableOn::Tag.find(params[:tag_id])
      @leagues = League.tagged_with(@tag)
      respond_with @tag, @leagues
    else
      @leagues = if params[:query]
        League.search_by_name(params[:query])
      else
        current_user.leagues
      end
      
      respond_with @leagues
    end
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
