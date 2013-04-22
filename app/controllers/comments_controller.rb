class CommentsController < ApplicationController
  self.responder = ApiResponder
  respond_to :json

  def index
    authorize! :index, Comment
    @comments = commentable.comments.includes(:user)
    respond_with commentable, @comments
  end

  def create
    @comment = commentable.comments.build(params[:comment])
    @comment.user = current_user
    authorize! :create, @comment
    @comment.save
    respond_with commentable, @comment
  end

  def update
    @comment = commentable.comments.find(params[:id])
    @comment.assign_attributes(params[:comment])
    authorize! :update, @comment
    @comment.save
    respond_with commentable, @comment
  end

  def destroy
    @comment = commentable.comments.find(params[:id])
    authorize! :destroy, @comment
    @comment.destroy
    respond_with commentable, @comment
  end

private

  def commentable
    @commentable ||= if params[:question_id]
      Question.find(params[:question_id])
    elsif params[:bet_id]
      Bet.find(params[:bet_id])
    else 
      League.find(params[:league_id]) 
    end
  end

  def current_league
    @current_league ||= if commentable.is_a?(League)
      commentable
    elsif commentable.is_a?(Question)
      commentable.league
    elsif commentable.is_a?(Bet)
      commentable.answer.question.league
    end
  end

end
