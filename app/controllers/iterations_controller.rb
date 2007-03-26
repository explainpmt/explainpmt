##############################################################################
# eXPlain Project Management Tool
# Copyright (C) 2005  John Wilger <johnwilger@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##############################################################################


class IterationsController < ApplicationController
  include CrudActions

  before_filter :require_current_project
  popups :select_stories, :assign_stories, :edit, :new, :allocation_for_iteration

  def mymodel
    Iteration
  end

  # If the project has no iterations, displays a page with a message to that
  # effect. Otherwise, tries to find either (in order of preference) a current
  # iteration, the previous iteration, or the next iteration and redirects to
  # that iteration's #show view
  def index
    iteration = @project.iterations.current
    iteration = @project.iterations.previous if iteration.nil?
    iteration = @project.iterations.next if iteration.nil?

    unless iteration.nil?
      flash.keep
      redirect_to :controller => 'iterations', :action => 'show',
                  :id => iteration.id.to_s,
                  :project_id => @project.id.to_s
    else
      @page_title = 'Iterations'
    end
  end

  # Displays a summary of the iteration and shows the list of story cards that
  # are assigned to the iteration.
  def show
    @iteration = Iteration.find(params[:id])
    @page_title = "Iteration: #{@iteration.start_date} - #{@iteration.stop_date}"
    @stories = Story.find_all_by_iteration_and_project(@iteration.id, @project.id)
    @projectIterations = @project.iterations
  end

  # Used to move stories between iterations and the backlog. A list of id
  # attributes of story objects should be passed in the parameter
  # "selected_stories", and the iteration to move the stories to should be
  # passed in the parameter "move_to" (if move_to is 0, the stories will be
  # moved to the backlog. 
  def move_stories
    change_story_assignment
    if params[:id]
      redirect_to :controller => 'iterations', :action => 'show',
                  :id => params[:id], :project_id => @project.id.to_s
    else
      redirect_to :controller => 'stories', :action => 'index',
                  :project_id => @project.id.to_s
    end
  end

  # Appears in a popup window and displays a list of defined stories in the
  # backlog that can be assigned to an iteration inside a form that will assign
  # the selected stories to the iteration being displayed.
  def select_stories
    @page_title = "Assign Story Cards"
    @stories = @project.stories.backlog.select { |s|
      s.status != Story::Status::New and
      s.status != Story::Status::Cancelled
    }
    @iteration = Iteration.find(params[:id])
  end

  # Essentially the same as #move_stories, but intended to render in a popup
  # window used by #select_stories
  def assign_stories
    change_story_assignment
    render :template => 'layouts/refresh_parent_close_popup'
  end
  
  # Exports stories for given iteration to Microsoft Excel
  def export
    headers['Content-Type'] = "application/vnd.ms-excel" 
    @iteration = Iteration.find(params[:id])
    @stories = Iteration.find_stories(params[:id])
    render :layout => false
  end
  
  #Exports tasks for given iteration to Microsoft Excel
  def export_tasks
    headers['Content-Type'] = "application/vnd.ms-excel" 
    @iteration = Iteration.find(params[:id])
    @stories = Iteration.find_stories(params[:id])
    render :layout => false
  end

  def allocation_for_iteration
    @iteration = Iteration.find(params[:id])
    @allocations = @iteration.points_by_user
    @users = @project.users
  end
  
  private

  # Does the actual work of changing the iteration assignment for #move_stories
  # and #assign_stories
  def change_story_assignment
    stories = ( params[:selected_stories] || [] ).map do |sid|
      Story.find(sid)
    end
    successes = []
    failures = []
    stories.each do |s|
      if params[:move_to].to_i == 0
        s.iteration = nil
      else
        s.iteration = Iteration.find(params[:move_to].to_i)
      end
      if s.save
        successes << "SC#{s.scid} has been moved."
      else
        failures << "SC#{s.scid} could not be moved. (make sure it is defined)"
      end
    end
    flash[:status] = successes.join("\n\n") unless successes.empty?
    flash[:error] = failures.join("\n\n") unless failures.empty?
  end
end

