class MembershipsController < ApplicationController
  authorize_resource :league, :except => :index
  load_and_authorize_resource :except => [:create, :index], :through => :league

  self.responder = ApiResponder
  respond_to :json

  def index
    @memberships = if current_league
      authorize! :index_memberships, League 
      @include_users = true
      current_league.memberships
    else
      authorize! :index, Membership
      @include_leagues = true
      current_user.memberships.includes(:league)
    end
    
    respond_with @memberships
  end

  def create
    if @league.priv? && !@league.authenticate(params[:league_password])
      render :json => { :errors => "Incorrect league password" }, :status => :unauthorized 
      return
    end

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
