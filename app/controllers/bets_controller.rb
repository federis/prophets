class BetsController < ApplicationController
  before_filter :load_answer, :except => :index

  self.responder = ApiResponder
  respond_to :json

  def index
    authorize! :index, Bet
    @bets = current_user.bets.where(:league_id => current_league.id)
    respond_with current_league, @bets
  end

  def create
    @bet = @answer.bets.build(params[:bet])
    @bet.user = current_user
    @bet.league = @answer.question.league
    authorize! :create, @bet
    @bet.save
    respond_with @answer, @bet
  end

  def destroy
    @bet = @answer.bets.find(params[:id])
    authorize! :destroy, @bet
    @bet.invalidate!
    respond_with @answer, @bet
  end

private

  def load_answer
    @answer = Answer.find(params[:answer_id])
  end
  
  def current_league
    params[:action] == "index" ? League.find(params[:league_id]) : @answer.question.league
  end
end
