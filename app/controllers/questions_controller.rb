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
end
