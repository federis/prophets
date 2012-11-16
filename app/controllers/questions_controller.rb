class QuestionsController < ApplicationController
  
  self.responder = ApiResponder
  respond_to :json

  def index
    authorize! "read_#{type}_questions".to_sym, current_league

    @questions = if params[:type] == "unapproved"
      current_league.questions.unapproved
    elsif params[:type] == "all"
      current_league.questions
    else
      current_league.questions.approved
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
    if params[:type] == "unapproved" || params[:type] == "all"
      params[:type]
    else
      "approved"
    end
  end
end
