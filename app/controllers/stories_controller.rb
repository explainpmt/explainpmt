class StoriesController < ApplicationController
  include CrudActions

  before_filter :require_current_project
  popups :show, :edit, :new_bulk, :assign_owner, :clone_story, :new_story_for_iteration, 
    :new_single, :edit_numeric_priority, :audit_story

  def mymodel
    Story
  end

  def index
    @page_title = "Backlog"
    if params[:show_cancelled]
      @stories = @project.stories.backlog
    elsif params[:show_all]
      @stories = @project.stories
    else
      @stories = @project.stories.not_cancelled_and_not_assigned_to_an_iteration
    end
  end

  def export_tasks
    export
  end

  def new_bulk
    newcommon
  end
  
  def new_single
    newcommon
  end

  def new_story_for_iteration
    newcommon
    @iteration = Iteration.find params[:iteration_id]
  end
  
  def newcommon
  	@story = Story.new
    @story.return_ids_for_aggregations
  end


  def create_many
    if params[:story_card_titles].empty?
      flash[:error] = 'Please enter at least one story card title.'
      render :action => "new_bulk", :layout => "popup"
    else
      params[:story_card_titles].each_line do |title|
      story = @project.stories.create(:title => title, :creator_id => current_user.id)
    end
      flash[:status] = 'New story cards created.'
      render :template => 'layouts/refresh_parent_close_popup'
    end
  end
  
  def create
    modify_risk_status_and_value_params
    @story = Story.new params[:story]
    @story.project = @project
    @story.iteration_id = params[:iteration_id]
    @story.creator_id = current_user.id
    if @story.save
      flash[:status] = 'The new story card has been saved.'
      render 'layouts/refresh_parent_close_popup'
    else
      if @story.iteration_id?
            redirect_to :controller => 'stories', :action => 'new_story_for_iteration',
                  :project_id => @project.id, :iteration_id => params[:iteration_id]
      else
        render :action => "new_single", :layout => "popup"
      end           
    end
  end

  def clone_story
  	editcommon
  	@story.title = "Clone Of: " + @story.title
    @iterationid = @story.iteration_id if @story.iteration_id?
  end
  
  def edit
	  editcommon
    @page_title = "Edit story card"
  end
  
  def editcommon
  	@story = Story.find params[:id]
    @story.return_ids_for_aggregations
  end

  def update
    @page_title = "Edit story card"
    @selected_main_menu_link = :none
    modify_risk_status_and_value_params
    story = Story.find params[:id]
    story.attributes = params[:story]
    story.updater_id = current_user.id
    if story.valid?
      story.audit_story
      story.save
      flash[:status] = 'The changes to the story card have been saved.'
      render :template => 'layouts/refresh_parent_close_popup'
    else
      render :action => "edit", :layout => "popup"
    end
  end

  def delete_common
    Story.destroy params[:id]
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

  def show
    @story = Story.find params[:id]
    @tasks = @story.tasks
    @acceptancetests = @story.acceptancetests
    @page_title = @story.title
  end

  def take_ownership
    story = Story.find params[:id]
    story.owner = current_user
    story.save
    current_user.reload
    flash[:status] = "SC#{story.scid} has been updated."
    redirect_to :controller => 'iterations', :action => 'show',
                :id => story.iteration.id.to_s, :project_id => @project.id.to_s
  end

  def release_ownership
    story = Story.find params[:id]
    story.owner = nil
    story.save
    current_user.reload    
    flash[:status] = "SC#{story.scid} has been updated."
    redirect_to :controller => 'iterations', :action => 'show',
                :id => story.iteration.id.to_s, :project_id => @project.id.to_s
  end
  
  def assign_owner
    @story = Story.find params[:id]
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
    story = Story.find params[:id]
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
    story = Story.find params[:id]
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
  	@story = Story.find params[:id]
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
