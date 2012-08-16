class MembershipsController < ApplicationController
  self.responder = ApiResponder
  respond_to :json

  before_filter :load_league

  def create
    @membership = @league.memberships.build
    @membership.user = current_user
    
    authorize! :create, @membership

    @membership.save
    respond_with @league, @membership
  end


private

  def load_league
    @league = League.find(params[:league_id])
  end

end
