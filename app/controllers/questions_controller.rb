class QuestionsController < ApplicationController
  load_and_authorize_resource :league
  load_and_authorize_resource :through => :league

  self.responder = ApiResponder
  respond_to :json

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
