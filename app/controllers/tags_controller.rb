class TagsController < ApplicationController
  self.responder = ApiResponder
  respond_to :json

  def index
    @tags = ActsAsTaggableOn::Tag.all
    authorize! :index, ActsAsTaggableOn::Tag
    respond_with @tags
  end

end
