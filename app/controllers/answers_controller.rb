class AnswersController < ApplicationController
  before_filter :load_question

  self.responder = ApiResponder
  respond_to :json

  def create
    @answer = @question.answers.build(params[:answer])
    @answer.user = current_user
    authorize! :create, @answer
    @answer.save
    respond_with @question, @answer
  end

  def update
    @answer = @question.answers.find(params[:id])
    @answer.assign_attributes(params[:answer])
    authorize! :update, @answer
    @answer.save
    respond_with @question, @answer
  end

  def destroy
    @answer = @question.answers.find(params[:id])
    authorize! :destroy, @answer
    @answer.destroy
    respond_with @question, @answer
  end

  def judge
    @answer = @question.answers.find(params[:id])
    authorize! :judge, @answer
    @answer.judge!(params[:answer][:correct] == "true", current_user)
    respond_with @question, @answer
  end


private

  def load_question
    @question = Question.find(params[:question_id])
  end

  def current_league
    @question.league
  end

end
