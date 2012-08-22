class QuestionsController < ApplicationController
  load_and_authorize_resource :league
  load_and_authorize_resource :through => :league, :except => :index
  authorize_resource :only => :index

  self.responder = ApiResponder
  respond_to :json

  def index
    @questions = @league.questions.approved
    respond_with @league, @questions
  end

  def create
    @question.user = current_user
    @question.save
    respond_with @league, @question
  end

  def update
    @question.approved_by = current_user if params[:question].delete(:approved) == "true"
    @question.assign_attributes(params[:question])
    authorize! :update, @question

    @question.save
    respond_with @league, @question
  end
end
