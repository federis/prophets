class MembershipsController < ApplicationController
  authorize_resource :league, :except => :index
  load_and_authorize_resource :except => [:create, :index], :through => :league

  self.responder = ApiResponder
  respond_to :json

  def index
    @memberships = current_user.memberships.includes(:league)
    authorize! :index, Membership
    @include_leagues = true
    respond_with @memberships
  end

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

end
