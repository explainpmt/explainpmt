class DashboardsController < ApplicationController
  skip_before_filter :require_current_project, :only => [:index]
  
  def show
    @stories = current_user.stories_for(@project).select { |s| !s.status.closed? }
    @tasks = current_user.tasks_for(@project)
    render :action => 'project'
  end
  
  def index
    @tasks = current_user.tasks
    @projects = current_user.projects
    if @projects.size == 1
      redirect_to project_dashboard_path(@projects.first)
    elsif @projects.empty?
      render :action => 'index_no_projects'
    else
      @stories = current_user.stories.select { |s| !s.status.closed? }
    end
  end
  
end
