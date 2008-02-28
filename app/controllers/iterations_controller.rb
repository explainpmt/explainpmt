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
      page.call 'showPopup', render(:partial => 'iteration_popup', :locals => {:url => project_iterations_path(@project)})
      page.call 'autoFocus', "iteration_name", 500
    end 
  end

  def edit
    @iteration = Iteration.find params[:id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'iteration_popup', :locals => {:url => project_iteration_path(@project, @iteration)})
      page.call 'autoFocus', "iteration_name", 500
    end 
  end
  
  def create
    iteration = Iteration.new params[:iteration]
    iteration.project = @project
    render :update do |page|
      if iteration.save
        flash[:status] = "New Release \"#{iteration.name}\" has been created."
        page.redirect_to project_iterations_path(@project)
      else
        page[:flash_notice].replace_html iteration.errors.full_messages[0]
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
        page[:flash_notice].replace_html iteration.errors.full_messages[0]
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

  def select_stories
    @page_title = "Assign Story Cards"
    @stories = @project.stories.backlog.select { |s|
      s.status != Story::Status::New and
        s.status != Story::Status::Cancelled
    }
    @iteration = Iteration.find params[:id]
  end

  def assign_stories
    change_story_assignment
    render :template => 'layouts/refresh_parent_close_popup'
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
    stories = ( params[:selected_stories] || [] ).map do |sid|
      Story.find(sid)
    end
    successes = []
    failures = []
    stories.each do |s|
      if params[:move_to].to_i == 0
        s.iteration = nil
      else
        s.iteration = Iteration.find params[:move_to].to_i
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

