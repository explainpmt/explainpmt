class StoriesController < ApplicationController
  before_filter :find_story, :except => [:index, :new, :create, :audit, :export, :export_tasks, :bulk_create, :create_many, :cancelled, :all, :search]

  def index
    @stories = @project.stories.backlog.not_cancelled
    respond_to do |format|
      format.html
      format.xml {
        render :xml => @stories.to_xml
      }
    end
  end
  
  ## TODO => make these specialized routes which pass a param or something to get into the real index method instead..
  def cancelled
    @stories = @project.stories.cancelled
    render :index
  end

  def all
    @stories = @project.stories
    render :index
  end

  def new
    @story = Story.new
  end

  def edit
  end

  def show
    @tasks = @story.tasks
    @acceptance_tests = @story.acceptance_tests
  end

  def create
    @story = Story.new params[:story]
    @story.project = @project
    @story.iteration = Iteration.find params[:iteration_id] if params[:iteration_id]
    @story.creator_id = current_user.id
    
    respond_to do |format|
      if @story.save
        msg = 'The new story card has been saved.'
        format.html {
          flash[:success] = msg
          redirect_to project_stories_path(@project)
        }
        format.js { render :json => { :message => msg } }
      else
        msg = @story.errors.full_messages.to_sentence
        format.html {
          flash[:errors] = msg
          render :new
        }
        format.js { render :json => { :errors => msg } }
      end
    end
  end

  def update
    @story.attributes = params[:story]
    @story.updater_id = current_user.id
    
    respond_to do |format|
      if @story.save
        msg = 'The changes to the story card have been saved.'
        format.html {
          flash[:success] = msg
          redirect_to project_stories_path(@project)
        }
        format.js { render :json => { :message => msg } }
      else
        msg = @story.errors.full_messages.to_sentence
        format.html {
          flash[:errors] = msg
          render :edit
        }
        format.js { render :json => { :errors => msg } }
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
    render :partial => "assign_owner_form"
  end

  def assign
    @story.assign_to(User.find params[:owner][:id])
    redirect_to request.referer
  end

  def clone_story
    @story.clone!
    redirect_to request.referer
  end

  def destroy
    @story.destroy
    flash[:status] = "Story \"#{@story.title}\" has been deleted."
    redirect_to request.referer
  end

  def move_up
    @story.move_higher
    redirect_to request.referer
  end

  def move_down
    @story.move_lower
    redirect_to request.referer
  end

  def edit_numeric_priority
    respond_to do |format|
      format.js { render :partial => "stories/edit_numeric_priority_form" }
    end
  end

  ## TODO => refactor this... I have no idea what's going on here.
  def set_numeric_priority
    new_pos = params[:story][:position]
    render :update do |page|
      if (new_pos.index(/\D/).nil?)
        last_story = @project.stories.last_position
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
    respond_to do |format|
      format.js { render :partial => "stories/audit" }
    end
  end

  def export
    headers['Content-Type'] = "application/vnd.ms-excel"
    @stories = @project.stories
    render :layout => false
  end
  alias :export_tasks :export

  def bulk_create
    render :partial => 'bulk_create_form'
  end

  def create_many
    st = params[:story][:titles]
    respond_to do |format|
      if st.present?
        params[:story][:titles].each_line do |title|
          @project.stories.create(:title => title, :creator_id => current_user.id)
        end
        msg = "New story cards created."
        format.html {
          flash[:success] = msg
          redirect_to project_stories_path(@project)
        }
        format.js { render :json => { :message => msg } }
      else
        msg = "Please enter at least one story card title."
        format.html {
          flash[:error] = msg
          redirect_to project_stories_path(@project)
        }
        format.js { render :json => { :errors => msg } }
      end
      
    end
  end

  def search
    query = params[:query_stories]
    unless query.blank?
      @stories = @project.stories.find(:all, :conditions => "stories.scid = '#{query[2..-1]}' or stories.title like '%#{query}%' or stories.description like '%#{query}%'")
    else
      @stories = @project.stories.backlog.not_cancelled
    end
    render :partial => 'backlog'
  end

  protected

  def find_story
    @story = Story.find params[:id]
  end

end
