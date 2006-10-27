class MainController < ApplicationController
  before_filter :check_authentication

  # The "main" view of the application for each user. Shows summary of projects
  # and recent activity on those projects that the user is associated with.
  def dashboard
    @my_projects = self.current_user.projects.sort { |a, b| a.name <=> b.name }
    @my_story_cards = self.current_user.story_cards.sort { |a,b| a.id <=> b.id }
  end
end
