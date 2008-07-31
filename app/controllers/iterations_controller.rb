class IterationsController < ApplicationController
  before_filter :find_iteration, :except => [:index, :new, :create, :move_stories]

  def index
    @project_iterations = @project.iterations
    @iteration = @project_iterations.current || @project_iterations.previous || @project_iterations.next
    @stories = @iteration.stories if @iteration
    render :action => 'iterations'
  end

  def show
    @stories = @iteration.stories
    @project_iterations = @project.iterations
    render :action => 'iterations'
  end

  def new
    common_popup(project_iterations_path(@project))
  end

  def edit
    common_popup(project_iteration_path(@project, @iteration))
  end

  def create
    @iteration = Iteration.new params[:iteration]
    @iteration.project = @project
    render :update do |page|
      if @iteration.save
        flash[:status] = "New Release \"#{@iteration.name}\" has been created."
        page.redirect_to project_iteration_path(@project, @iteration)
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@iteration.errors.full_messages[0]) %>"
      end
    end
  end

  def update
    render :update do |page|
      if @iteration.update_attributes(params[:iteration])
        flash[:status] = "Iteration \"#{@iteration.name}\" has been updated."
        page.redirect_to project_iterations_path(@project)
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@iteration.errors.full_messages[0]) %>"
      end
    end
  end

  def destroy
    @iteration.destroy
    flash[:status] = "#{@iteration.name} has been deleted."
    redirect_to project_iterations_path(@project)
  end

  def allocation
    @allocations = @iteration.points_by_user
    @users = @project.users
    render :update do |page|
      page.call 'showPopup', render(:partial => 'allocation_popup')
      page.call 'sortAllocation'
    end
  end

  def select_stories
    @stories = @project.stories.backlog.select { |s|
      s.status != Story::Status::New and
      s.status != Story::Status::Cancelled
    }
    render :update do |page|
      page.call 'showPopup', render(:partial => 'select_stories')
    end
  end

  def assign_stories
    change_story_assignment
    redirect_to project_iteration_path(@project, @iteration)
  end

  def move_stories
    change_story_assignment
    redirect_to request.referer
  end

  def export
    respond_to do |format|
      @stories = @iteration.stories
      format.html {
        headers['Content-Type'] = "application/vnd.ms-excel"
        render :layout => false
      }
      format.xml {
        render :xml => @iteration.to_xml(:include => { :stories => { :include => [:tasks, :acceptancetests] } } )
      }
    end
  end
  alias export_tasks export

  protected
  def find_iteration
    @iteration = Iteration.find params[:id]
  end

  def common_popup(url)
    render :update do |page|
      page.call 'showPopup', render(:partial => 'iteration_form', :locals => {:url => url})
    end
  end

  def change_story_assignment
    iteration = Iteration.find_by_id(params[:move_to])
    stories = Story.find(params[:selected_stories] || [])
    set_status_and_error_for(Story.assign_many_to_iteration(iteration, stories))
  end
end
