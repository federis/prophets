class MembershipsController < ApplicationController
  load_and_authorize_resource :league, :except => :create
  load_and_authorize_resource :except => :create, :through => :league

  self.responder = ApiResponder
  respond_to :json

  before_filter :load_league

  def create
    @membership = @league.memberships.build(params[:membership])
    @membership.user = current_user if @membership.user_id.nil?
    
    authorize! :create, @membership

    @membership.save
    respond_with @league, @membership
  end

  def destroy
    @membership.destroy
    respond_with @membership
  end


private

  def load_league
    @league = League.find(params[:league_id])
  end

end
