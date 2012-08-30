class BetsController < ApplicationController
  before_filter :load_answer

  self.responder = ApiResponder
  respond_to :json

  def create
    @bet = @answer.bets.build(params[:bet])
    @bet.user = current_user
    authorize! :create, @bet
    @bet.save
    respond_with @answer, @bet
  end

  def destroy
    @bet = @answer.bets.find(params[:id])
    authorize! :destroy, @bet
    @bet.destroy
    respond_with @answer, @bet
  end

private

  def load_answer
    @answer = Answer.find(params[:answer_id])
  end
  
  def current_league
    @answer.question.league
  end
end
