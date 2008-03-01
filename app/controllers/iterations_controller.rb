class IterationsController < ApplicationController
  before_filter :find_iteration, :except => [:index, :new, :create, :move_stories]
  
  def find_iteration
    @iteration = Iteration.find params[:id]
  end
  
  def index
    iterations = @project.iterations
    iteration = iterations.current || iterations.previous || iterations.next
    redirect_to project_iteration_path(@project, iteration) unless iteration.nil?
  end

  def show
    @stories = @iteration.stories
    @project_iterations = @project.iterations
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
        page.redirect_to project_iterations_path(@project)
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
    headers['Content-Type'] = "application/vnd.ms-excel" 
    @stories = @iteration.stories
    render :layout => false
  end
  alias export_tasks export
  
  protected
  def common_popup(url)
    render :update do |page|
      page.call 'showPopup', render(:partial => 'iteration_form', :locals => {:url => url})
    end
  end

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

