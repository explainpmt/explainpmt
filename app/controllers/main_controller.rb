class MainController < ApplicationController
  before_filter :check_authentication

  # The "main" view of the application for each user. Shows summary of projects
  # and recent activity on those projects that the user is associated with.
  def dashboard
    @my_projects = self.current_user.projects.sort { |a, b| a.name <=> b.name }
    @my_story_cards = self.current_user.story_cards.sort { |a,b| a.id <=> b.id }
    @upcoming_milestones = Milestone.find( :all ).select do |m|
      m.project.users.include? current_user and m.date >= Date.today and m.date <= ( Date.today + 30 )
    end
    @upcoming_milestones.sort! { |a,b| a.date <=> b.date }
  end
end
