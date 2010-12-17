class DashboardController < ApplicationController
  
  before_filter :require_user
  
  def index
    @tasks = current_user.tasks
    @projects = current_user.projects
  end
  
end