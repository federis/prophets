class ActivitiesController < ApplicationController
  respond_to :json

  def index
    authorize! :read, current_league
    @activities = current_league.activities.page(params[:page])

    respond_with current_league, @activities
  end
end
