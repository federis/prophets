class LeaderboardController < ApplicationController
  respond_to :json

  def index
    authorize! :read, current_league
    @leaders = current_league.memberships.select("memberships.*, row_number() over (order by (memberships.balance + memberships.outstanding_bets_value) DESC) as leaderboard_rank")
                                         .includes(:user)
                                         .order("(memberships.balance + memberships.outstanding_bets_value) DESC").limit(10)
  end

end
