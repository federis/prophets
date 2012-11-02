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
    @commentable ||= params[:question_id] ? Question.find(params[:question_id]) : League.find(params[:league_id]) 
  end

  def current_league
    @current_league ||= commentable.is_a?(League) ? commentable : commentable.league
  end

end
