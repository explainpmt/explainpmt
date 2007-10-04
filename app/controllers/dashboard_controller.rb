class DashboardController < ApplicationController
  def index
    if @project
      @page_title = "Dashboard"
      @stories = current_user.stories_for(@project).select { |s| !s.status.closed? }
      @tasks = current_user.tasks_for(@project)
      render :action => 'project'
    else
      @page_title = 'Overview'
      @tasks = current_user.tasks
      @projects = current_user.projects
      if @projects.size == 1
        redirect_to :controller => 'dashboard', :action => 'index',
                    :project_id => @projects.first.id
      elsif @projects.empty?
        render :action => 'index_no_projects'
      else
        @stories = current_user.stories.select { |s| !s.status.closed? }
      end
    end
  end
end
