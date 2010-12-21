class DashboardController < ApplicationController
  
  before_filter :require_user
  
  def index
    @tasks = current_user.tasks
    @projects = current_user.projects
  end
  
  def show
    @stories = @project.stories.incomplete.for_user(current_user)
    @tasks = @project.tasks.incomplete.for_user(current_user)
  end
end