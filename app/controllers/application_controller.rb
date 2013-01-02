class ApplicationController < ActionController::Base
  self.responder = ApiResponder
  
  protect_from_forgery
  
  before_filter :authenticate_user!

  check_authorization :unless => :devise_controller?

private

  def current_league
    @league ||= League.find(params[:league_id]) if params[:league_id]
  end

  def current_membership
    @current_membership ||= current_user.membership_in_league(current_league)
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, current_league)
  end

end
