class LeaderboardController < ApplicationController
  respond_to :json

  def index
    authorize! :read, current_league
    @leaders = current_league.memberships.order("(memberships.balance + memberships.outstanding_bets_value) DESC")
  end

end
