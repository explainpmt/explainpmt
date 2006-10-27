class MainController < ApplicationController
  before_filter :check_authentication

  # The "main" view of the application for each user. Shows summary of projects
  # and recent activity on those projects that the user is associated with.
  def dashboard
    @my_projects = self.current_user.projects.sort { |a, b| a.name <=> b.name }
  end
end
