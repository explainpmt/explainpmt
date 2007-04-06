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


class StoriesController < ApplicationController
  include CrudActions

  before_filter :require_current_project
  popups :show, :edit, :new_bulk, :assign_owner, :clone_story, :new_story_for_iteration, 
    :new_single, :edit_numeric_priority, :audit_story

  def mymodel
    Story
  end
  # Lists all of the stories in the project 'Backlog' (stories that have no
  # iteration). Stories with a "cancelled" status are hidden by default. They
  # can be displayed by passing the request parameter 'show_cancelled' (with any
  # non-blank value).
  def index
    @page_title = "Backlog"
    if params[:show_cancelled]
      @stories = Project.find_all_stories_not_assigned_to_an_iteration(@project.id)
    elsif params[:show_all]
      @stories = Project.find_all_stories(@project.id)
    else
      @stories = Project.find_all_stories_not_cancelled_and_not_assigned_to_an_iteration(@project.id)
    end
  end

  def export_tasks
    export
  end

  # Displays a form for creating a new story card.
  def new_bulk
	newcommon
  end
  
  def new_single
	newcommon
  end

  def new_story_for_iteration
	newcommon
    @iteration = Iteration.find(params[:iteration_id])
  end
  
  # Common logic used for new and new for iteration
  def newcommon
  	@story = session[:new_story] || Story.new
    session[:new_story] = nil
    @story.return_ids_for_aggregations
  end


  # Creates new story cards based on the story titles posted form the #new
  # action.
  def create_many
    if params[:story_card_titles].empty?
      flash[:error] = 'Please enter at least one story card title.'
      redirect_to :controller => 'stories', :action => 'new_bulk', :project_id => @project
    else
      params[:story_card_titles].each_line do |title|
        story = @project.stories.create(:title => title, :creator_id => session[:current_user].id)
      end
      flash[:status] = 'New story cards created.'
      render :template => 'layouts/refresh_parent_close_popup'
    end
  end
  
  def create
    modify_risk_status_and_value_params
    story = Story.new(params[:story])
    story.project = @project
    story.iteration_id = params[:iteration_id]
    story.creator_id = session[:current_user].id
    if story.valid?
      story.save
      flash[:status] = 'The new story card has been saved.'
      render 'layouts/refresh_parent_close_popup'
    else
      session[:new_story] = story
      if(story.iteration_id?)
            redirect_to :controller => 'stories', :action => 'new_story_for_iteration',
                  :project_id => @project.id, :iteration_id => params[:iteration_id]
      else
      redirect_to :controller => 'stories', :action => 'new_single',
                  :project_id => @project.id
      end           
    end
  end

 #Displays the form for cloning a story
  def clone_story
	editcommon
	@story.title = "Clone Of: " + @story.title
	if(@story.iteration_id?)
	 @iterationid = @story.iteration_id
	end
  end
  
  # Displays the form for editing a story card's information.
  def edit
	editcommon
    @page_title = "Edit story card"
  end
  
  # Common logic used for edit and cloning
  def editcommon
  	@story = session[:story] || Story.find(params[:id])
    session[:story] = nil
    @story.return_ids_for_aggregations
  end


  # Updates a story card with the information posted from the #edit action.
  def update
    @page_title = "Edit story card"
    @selected_main_menu_link = :none
    modify_risk_status_and_value_params
    story = Story.find(params[:id])
    story.attributes = params[:story]
    story.updater_id = session[:current_user].id
    if story.valid?
      story.audit_story
      story.save
      flash[:status] = 'The changes to the story card have been saved.'
      render :template => 'layouts/refresh_parent_close_popup'
    else
      session[:edit_story] = story
      redirect_to :controller => 'stories', :action => 'edit',
                  :id => story.id.to_s, :project_id => @project.id.to_s
    end
  end

  # Destroys the story card identified by the 'id' request parameter.
  def delete_common
    Story.destroy(params[:id])
    flash[:status] = 'The story card was deleted.'
  end
  
  def delete_from_backlog
    delete_common
    redirect_to :controller => 'stories', :action => 'index',
                  :project_id => @project.id.to_s
    
  end
  
  def delete_from_dashboard
    delete_common
    redirect_to :controller => 'dashboard', :action => 'index',
                  :project_id => @project.id
  end
  
  def delete_from_iteration
    delete_common
    redirect_to :controller => 'iterations', :action => 'show',
                  :id => (params[:iteration_id]),
                  :project_id => @project.id
  end

  # Displays the details for the story card identified by the 'id' request
  # parameter.
  def show
    @story = Story.find(params[:id])
    @tasks = @story.tasks
    @acceptancetests = @story.acceptancetests
    @page_title = @story.title
  end

  # Sets the storycard's Story#owner attribute to the currently logged in user.
  def take_ownership
    story = Story.find(params[:id])
    story.owner = session[:current_user]
    story.save
    session[:current_user].reload
    flash[:status] = "SC#{story.scid} has been updated."
    redirect_to :controller => 'iterations', :action => 'show',
                :id => story.iteration.id.to_s, :project_id => @project.id.to_s
  end

  # Sets the story's owner to nil
  def release_ownership
    story = Story.find(params[:id])
    story.owner = nil
    story.save
    session[:current_user].reload    
    flash[:status] = "SC#{story.scid} has been updated."
    redirect_to :controller => 'iterations', :action => 'show',
                :id => story.iteration.id.to_s, :project_id => @project.id.to_s
  end
  
  def assign_owner
    @story = Story.find(params[:id])
    @users = @project.users
  end
    
  def move_acceptancetests
    change_acceptancetest_assignment
    redirect_to :controller => 'acceptancetests', :action => 'index',
                  :id => params[:id], :project_id => @project.id 
  end
  
  def change_acceptancetest_assignment
    acceptancetests = (params[:selected_acceptancetests] || []).map do |sid|
      Acceptancetest.find(sid)
    end
    successes = []
    failures = []
    acceptancetests.each do |s|
      if params[:move_to].to_i == 0
        s.story = nil
      else
        s.story = Story.find(params[:move_to].to_i)
      end
      if s.save
        successes << "Acceptance Tests has been moved."
      else
        failures << "Acceptance Tests could not be moved."
      end
    end
    flash[:status] = successes.join("\n\n") unless successes.empty?
    flash[:error] = failures.join("\n\n") unless failures.empty?
  end
  
  def increase_numeric_priority
  	story = Story.find(params[:id])
	story.move_higher
	if params[:iteration_id]
	  	redirect_to :controller => 'iterations', :action => 'show',
                  :project_id => @project.id, :id => params[:iteration_id]
	else
 	redirect_to :controller => 'stories', :action => 'index',
                  :project_id => @project.id
    end
  end
  
  def decrease_numeric_priority
  	story = Story.find(params[:id])
  	story.move_lower
	if params[:iteration_id]
	  	redirect_to :controller => 'iterations', :action => 'show',
                  :project_id => @project.id, :id => params[:iteration_id]
	else
 	redirect_to :controller => 'stories', :action => 'index',
                  :project_id => @project.id
    end
  end
  
  def edit_numeric_priority
  	@story = Story.find(params[:id])
  end
  
  def set_numeric_priority
  	newPos = params[:story][:position]
  	if (newPos.to_i.to_s.length == newPos.length)
	  	lastStory = Story.find(:first, :conditions => "project_id = #{@project.id}", :order => "position DESC")
	  	if(newPos.to_i <= lastStory.position)
	  		story = Story.find(params[:id])
	  		story.insert_at(newPos)
	 		flash[:status] = 'The changes to the story card have been saved.'
	     	render 'layouts/refresh_parent_close_popup'
	    else
	     	flash[:error] = 'Position was not updated.  Value can not be greater than last position.'
 		    render 'layouts/refresh_parent_close_popup'
	    end
 	else
 		flash[:error] = 'Position was not updated.  You must specify a numeric value.'
 		      render 'layouts/refresh_parent_close_popup'
    end
  end
  
  def audit_story
    @changes = Audit.find(:all, :conditions => ["project_id = #{@project.id} AND audited_object_id = #{@params[:id]} AND object = 'Story'"], :order => "created_at DESC")
  end

  protected

  # Sets the parameter values for a story's status, value and risk to the
  # actual objects that need to be assigned based on the integer value
  # originally passed in that parameter.
  def modify_risk_status_and_value_params
    if params[:story]
      if params[:story][:status]
        params[:story][:status] =
          Story::Status.new(params[:story][:status].to_i)
      end
      if params[:story][:value]
        params[:story][:value] =
          Story::Value.new(params[:story][:value].to_i)
      end
      if params[:story][:risk]
        params[:story][:risk] =
          Story::Risk.new(params[:story][:risk].to_i)
      end
    end
  end
 
end
