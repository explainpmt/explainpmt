class StoriesController < ApplicationController
  before_filter :find_story, :except => [:index, :new, :create, :audit, :export, :export_tasks, :bulk_create, :create_many, :cancelled, :all, :search]

  def index
    @stories = @project.stories.backlog.select { |s|
      s.status != Story::Status::Cancelled
    }
    respond_to do |format|
      format.html { }
      format.xml {
        render :xml => @stories.to_xml
      }
    end
  end

  def cancelled
    @stories = @project.stories.cancelled
    render :action => 'index'
  end

  def all
    @stories = @project.stories
    render :action => 'index'
  end

  def new
    url = params[:iteration_id] ? project_iteration_stories_path(@project, Iteration.find(params[:iteration_id])) : project_stories_path(@project)
    common_popup(url)
  end

  def edit
    @story.return_ids_for_aggregations
    common_popup(project_story_path(@project, @story))
  end

  def show
    @tasks = @story.tasks
    @acceptancetests = @story.acceptancetests
  end

  def create
    modify_risk_status_and_value_params
    @story = Story.new params[:story]
    @story.project = @project
    @story.iteration = Iteration.find params[:iteration_id] if params[:iteration_id]
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

  def take_ownership
    @story.assign_to(current_user)
    redirect_to request.referer
  end

  def release_ownership
    @story.release_ownership
    redirect_to request.referer
  end

  def assign_ownership
    @users = @project.users
    render :update do |page|
      page.call 'showPopup', render(:partial => 'assign_owner_form')
    end
  end

  def assign
    @story.assign_to(User.find params[:owner][:id])
    redirect_to request.referer
  end

  def clone_story
    render :update do |page|
      @story.clone!
      page.redirect_to request.referer
    end
  end

  def destroy
    render :update do |page|
      @story.destroy
      flash[:status] = "Story \"#{@story.title}\" has been deleted."
      page.redirect_to request.referer
    end
  end

  def move_up
    render :update do |page|
      @story.move_higher
      page.redirect_to request.referer
    end
  end

  def move_down
    render :update do |page|
      @story.move_lower
      page.redirect_to request.referer
    end
  end

  def edit_numeric_priority
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
          @story.insert_at(new_pos)
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
      page.call 'showPopup', render(:partial => 'stories/audit')
      page.call 'sortAudits'
    end
  end

  def export
    headers['Content-Type'] = "application/vnd.ms-excel"
    render :layout => false
    @stories = @project.stories
  end
  alias export_tasks export

  def bulk_create
    render :update do |page|
      page.call 'showPopup', render(:partial => 'stories/bulk_create_form')
    end
  end

  def create_many
    render :update do |page|
      if params[:story][:titles].empty?
        page[:flash_notice].replace_html :inline => "<%= error_container('Please enter at least one story card title.') %>"
      else
        params[:story][:titles].each_line do |title|
          @project.stories.create(:title => title, :creator_id => current_user.id)
        end
        flash[:status] = 'New story cards created.'
        page.call 'location.reload'
      end
    end
  end

  def search
    query = params[:query_stories]
    unless query.blank?
      @stories = @project.stories.find(:all, :conditions => "stories.scid = '#{query[2..-1]}' or stories.title like '%#{query}%' or stories.description like '%#{query}%'")
    else
      @stories = @project.stories.backlog.select { |s|
        s.status != Story::Status::Cancelled
      }
    end
    render :partial => 'display_backlog'
  end

  protected

  def find_story
    @story = Story.find params[:id]
  end

  def common_popup(url)
    render :update do |page|
      page.call 'showPopup', render(:partial => 'stories/story_form', :locals => {:url => url})
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

end
