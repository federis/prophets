class QuestionsController < ApplicationController
  
  self.responder = ApiResponder
  respond_to :json

  def index
    authorize! "read_#{type}_questions".to_sym, current_league

    @questions = case type
    when "unapproved"
      current_league.questions.unapproved
    when "pending_judgement"
      current_league.questions.pending_judgement
    when "complete"
      current_league.questions.complete
    else
      current_league.questions.currently_running
    end

    @include_answers = true

    respond_with current_league, @questions
  end

  def show
    @question = current_league.questions.find(params[:id])
    authorize! :show, @question
    @include_answers = true
    respond_with current_league, @question
  end

  def create
    @question = current_league.questions.build(params[:question])
    @question.user = current_user

    authorize! :create, @question
    @question.save
    respond_with current_league, @question
  end

  def update
    @question = current_league.questions.find(params[:id])
    authorize! :update, @question

    @question.assign_attributes(params[:question])
    authorize! :update, @question #needs to happen twice, so that they don't overwrite attrs on a question that they shouldn't

    @question.save
    respond_with current_league, @question
  end

  def approve
    @question = current_league.questions.find(params[:id])
    authorize! :approve, @question
    @question.approve!(current_user)
    respond_with current_league, @question
  end

  def destroy
    @question = current_league.questions.find(params[:id])
    authorize! :destroy, @question
    @question.destroy
    respond_with current_league, @question
  end

private

  def type
    if %w(unapproved pending_judgement complete).include?(params[:type])
      params[:type]
    else
      "currently_running"
    end
  end
end
