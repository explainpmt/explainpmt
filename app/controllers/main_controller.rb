class MainController < ApplicationController
  before_filter :check_authentication

  # The "main" view of the application for each user. Shows summary of projects
  # and recent activity on those projects that the user is associated with.
  def dashboard
  end
end
