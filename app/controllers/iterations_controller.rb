class IterationsController < ApplicationController
  before_filter :require_current_project

  def index
    iterations = @project.iterations
    iteration = iterations.current || iterations.previous || iterations.next
    redirect_to project_iteration_path(@project, iteration) unless iteration.nil?
  end

  def show
    @iteration = Iteration.find params[:id]
    @stories = @iteration.stories
    @project_iterations = @project.iterations
  end
  
  def new
    render :update do |page|
      page.call 'showPopup', render(:partial => 'iteration_form', :locals => {:url => project_iterations_path(@project)})
    end 
  end

  def edit
    @iteration = Iteration.find params[:id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'iteration_form', :locals => {:url => project_iteration_path(@project, @iteration)})
    end 
  end
  
  def create
    @iteration = Iteration.new params[:iteration]
    @iteration.project = @project
    render :update do |page|
      if @iteration.save
        flash[:status] = "New Release \"#{@iteration.name}\" has been created."
        page.redirect_to project_iterations_path(@project)
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@iteration.errors.full_messages[0]) %>"
      end
    end    
  end

  def update
    iteration = Iteration.find params[:id]
    render :update do |page|
      if iteration.update_attributes(params[:iteration])
        flash[:status] = "Iteration \"#{iteration.name}\" has been updated."
        page.redirect_to project_iterations_path(@project)
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@iteration.errors.full_messages[0]) %>"
      end
    end
  end

  def allocation
    @iteration = Iteration.find params[:id]
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
    @iteration = Iteration.find params[:id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'select_stories')
    end 
  end

  def assign_stories
    change_story_assignment
    @iteration = Iteration.find params[:id]
    redirect_to project_iteration_path(@project, @iteration)
  end  

  def move_stories
    change_story_assignment
    if params[:id]
      @iteration = Iteration.find params[:id]
      redirect_to project_iteration_path(@project, @iteration)
    else
      redirect_to project_stories_path(@project)
    end
  end
  
  def export
    headers['Content-Type'] = "application/vnd.ms-excel" 
    @iteration = Iteration.find params[:id]
    @stories = @iteration.stories
    render :layout => false
  end
  
  def export_tasks
    headers['Content-Type'] = "application/vnd.ms-excel" 
    @iteration = Iteration.find params[:id] 
    @stories = @iteration.stories
    render :layout => false
  end
  
  private

  def change_story_assignment
    stories = Story.find(params[:selected_stories] || [])
    successes, failures = [], []
    stories.each do |s|
      s.iteration = Iteration.find_by_id(params[:move_to])
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

