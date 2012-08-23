class QuestionsController < ApplicationController
  authorize_resource :league
  load_and_authorize_resource :through => :league, :except => :index

  self.responder = ApiResponder
  respond_to :json

  def index
    authorize! "read_#{type}_questions".to_sym, @league

    @questions = if params[:type] == "unapproved"
      @league.questions.unapproved
    elsif params[:type] == "all"
      @league.questions
    else
      @league.questions.approved
    end

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

private

  def type
    if params[:type] == "unapproved" || params[:type] == "all"
      params[:type]
    else
      "approved"
    end
  end
end
