class StoriesController < ApplicationController
  before_filter :require_current_project

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
  
  def new
    render :update do |page|
      page.call 'showPopup', render(:partial => 'stories/story_form', :locals => {:url => project_stories_path(@project)})
      page.call 'autoFocus', "story_name", 500
    end 
  end

  def edit
    @story = Story.find params[:id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'stories/story_form', :locals => {:url => project_story_path(@project, @story)})
      page.call 'autoFocus', "story_name", 500
    end 
  end

  def show
    @story = Story.find params[:id]
    @tasks = @story.tasks
    @acceptancetests = @story.acceptancetests
  end
  
  def create
    modify_risk_status_and_value_params
    @story = Story.new params[:story]
    @story.project = @project
    @story.iteration_id = params[:iteration_id]
    @story.creator_id = current_user.id
    render :update do |page|
      if @story.save
        flash[:status] = 'The new story card has been saved.'
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@story.errors.full_messages[0]) %>"      
      end
    end
  end
  
  def update
    modify_risk_status_and_value_params
    @story = Story.find params[:id]
    @story.attributes = params[:story]
    @story.updater_id = current_user.id
    render :update do |page|
      if @story.valid?
        @story.audit_story
        @story.save
        flash[:status] = 'The changes to the story card have been saved.'
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@story.errors.full_messages[0]) %>"           
      end
    end
  end
  
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

  def take_ownership
    @story = Story.find params[:id]
    @story.owner = current_user
    @story.save
    current_user.reload
    render :update do |page|
      page.call 'location.reload'
    end
  end
  
  def release_ownership
    @story = Story.find params[:id]
    @story.owner = nil
    @story.save
    current_user.reload
    render :update do |page|
      page.call 'location.reload'
    end
  end

  def assign_ownership
    @story = Story.find params[:id]
    @users = @project.users
    render :update do |page|
      page.call 'showPopup', render(:partial => 'assign_owner_form')
    end 
  end
  
  def assign
    @story = Story.find params[:id]
    user = User.find params[:owner][:id]
    @story.owner = user
    @story.save
    current_user.reload
    render :update do |page|
      page.call 'location.reload'
    end
  end
  
  def clone_story
    @story = Story.find params[:id]
    story = @story.clone
    story.title = "Clone:" + @story.title
    story.scid = nil
    story.save!
    render :update do |page|
      page.call 'location.reload'
    end 
  end
  
  def destroy
    @story = Story.find params[:id]
    render :update do |page|
      if @story.destroy
        flash[:status] = "Story \"#{@story.title}\" has been deleted."
        page.call 'location.reload'
      end
    end
  end
  
  def move_up
    story = Story.find params[:id]
  	story.move_higher
    render :update do |page|
      page.call 'location.reload'
    end
  end
  
  def move_down
    story = Story.find params[:id]
    story.move_lower
    render :update do |page|
      page.call 'location.reload'
    end
  end  

  def edit_numeric_priority
  	@story = Story.find params[:id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'stories/edit_numeric_priority_form')
    end
  end

  def set_numeric_priority
  	new_pos = params[:story][:position]
    render :update do |page|
      if (new_pos.index(/\D/).nil?)
        last_story = @project.last_story
        if(new_pos.to_i <= last_story.position)
          story = Story.find(params[:id])
          story.insert_at(new_pos)
          flash[:status] = 'The changes to the story card have been saved.'
          page.call 'location.reload'
        else
          @error = 'Position was not updated.  Value can not be greater than last position.'
          page[:flash_notice].replace_html :inline => "<%= error_container(@error) %>" 
        end
      else
        @error = 'Position was not updated.  You must specify a numeric value.'
        page[:flash_notice].replace_html :inline => "<%= error_container(@error) %>" 
      end
    end
  end
  
  def audit
    @changes = Story.find(params[:id]).audits
    render :update do |page|
      unless @changes.empty?
        page.call 'showPopup', render(:partial => 'stories/audit')
        page.call 'sortAudits'
      end
    end 
  end
  
  
  
  
  def export_tasks
    export
  end

  def new_bulk
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
 
end
