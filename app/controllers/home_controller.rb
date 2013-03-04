class HomeController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_authorization_check :only => :index

  def index
  end
end
