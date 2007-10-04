class DashboardController < ApplicationController
  def index
    user = current_user
    if @project
      project = @project.id
      @page_title = "Dashboard"
      @stories = user.find_all_stories_by_project(project)
      @stories = @stories.select { |s| !s.status.closed? }
      @tasks = Task.find_all_by_user_and_project(user.id, project)
      render :action => 'project'
    else
      @page_title = 'Overview'
      @tasks = Task.find_all_by_user(user.id)
      @projects = user.projects
      if @projects.size == 1
        redirect_to :controller => 'dashboard', :action => 'index',
                    :project_id => @projects.first.id
      elsif @projects.empty?
        render :action => 'index_no_projects'
      else
        @stories = user.stories
        @stories = @stories.select { |s| !s.status.closed? }
      end
    end
  end
end
