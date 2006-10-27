=begin License
  eXPlain Project Management Tool
  Copyright (C) 2005  John Wilger <johnwilger@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
=end LICENSE

class DashboardController < ApplicationController
  # If called without a project_id parameter, displays summary information for
  # all projects for which the user is a team member. If a project_id parameter
  # is passed, summary information will be displayed for that project. Also, if
  # a user is only on one project team, but no project id is passed, the user
  # will be redirected to the dashboard of the project to which they belong.
  def index
    if @project
      @page_title = "Dashboard"
      @stories = session[:current_user].stories.find_all([ "project_id = ?",
                                                            @project.id ])
      @stories = @stories.select { |s| !s.status.closed? }
      @stories = sort_stories(@stories)
      render 'dashboard/project'
    else
      @page_title = 'Overview'
      @projects = session[:current_user].projects
      if @projects.size == 1
        redirect_to :controller => 'dashboard', :action => 'index',
                    :project_id => @projects.first.id
      elsif @projects.empty?
        render 'dashboard/index_no_projects'
      else
        @stories = session[:current_user].stories
        @stories = @stories.select { |s| !s.status.closed? }
        @stories = sort_stories(@stories)
      end
    end
  end

  protected

  # Uses SortHelper to sort the list of story cards
  def sort_stories(stories)
    if @project.nil?
      SortHelper.columns = %w( project.name scid title points priority risk
                               status )
    else
      SortHelper.columns = %w( scid title points priority risk status )
    end
    SortHelper.default_order = %w( status priority risk )
    stories = stories.sort do |a,b|
      SortHelper.sort(a,b,params)
    end
    return stories
  end
end
