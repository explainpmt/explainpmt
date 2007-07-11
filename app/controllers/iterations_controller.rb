class IterationsController < ApplicationController
  include CrudActions

  before_filter :require_current_project
  popups :select_stories, :assign_stories, :edit, :new, :allocation_for_iteration

  def mymodel
    Iteration
  end

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

  def show
    @iteration = Iteration.find params[:id]
    @page_title = "Iteration: #{@iteration.start_date} - #{@iteration.stop_date}"
    @stories = Story.find_all_by_iteration_and_project(@iteration.id, @project.id)
    @projectIterations = @project.iterations
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
    @stories = Iteration.find_stories params[:id]
    render :layout => false
  end
  
  def export_tasks
    headers['Content-Type'] = "application/vnd.ms-excel" 
    @iteration = Iteration.find params[:id] 
    @stories = Iteration.find_stories params[:id]
    render :layout => false
  end

  def allocation_for_iteration
    @iteration = Iteration.find params[:id]
    @allocations = @iteration.points_by_user
    @users = @project.users
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

