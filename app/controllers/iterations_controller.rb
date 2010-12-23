class IterationsController < ApplicationController
  before_filter :find_iteration, :except => [:index, :new, :create, :move_stories]

  def index
    @project_iterations = current_project.iterations
    @iteration = @project_iterations.current.first || @project_iterations.previous.first || @project_iterations.next.first
    @stories = @iteration.stories if @iteration
    respond_to do |format|
      format.html
      format.xml {
        render :xml => @project_iterations.to_xml(:include => { :stories => { :include => [:tasks, :acceptance_tests] } } )
      }
    end
  end

  def show
    @stories = @iteration.stories
    @project_iterations = current_project.iterations
    respond_to do |format|
      format.html { render :index }
      format.xml {
        render :xml => @iteration.to_xml(:include => { :stories => { :include => [:tasks, :acceptance_tests] } } )
      }
    end
  end

  def new
    @iteration = Iteration.new
  end

  def create
    @iteration = current_project.iterations.new(params[:iteration])
    if @iteration.save
      render_success("New Release \"#{@iteration.name}\" has been created.") { redirect_to project_iteration_path(current_project, @iteration) }
    else
      render_errors(@iteration.errors.full_messages.to_sentence) { render :new }
    end
  end

  def update
    if @iteration.update_attributes(params[:iteration])
      render_success("Iteration \"#{@iteration.name}\" has been updated.") { redirect_to project_iteration_path(current_project, @iteration) }
    else
      render_errors(@iteration.errors.full_messages.to_sentence) { render :edit }
    end
  end

  def destroy
    @iteration.destroy
    flash[:success] = "#{@iteration.name} has been deleted."
    redirect_to project_iterations_path(current_project)
  end

  def allocation
    @allocations = @iteration.points_by_user
    @users = current_project.users
    # render :update do |page|
    #   page.call 'showPopup', render(:partial => 'allocation_popup')
    #   page.call 'sortAllocation'
    # end
  end

  def select_stories
    @stories = current_project.stories.backlog.select { |s|
      s.status != :new and
      s.status != :cancelled
    }
    # render :update do |page|
    #   page.call 'showPopup', render(:partial => 'select_stories')
    # end
  end

  def assign_stories
    change_story_assignment
    redirect_to project_iteration_path(current_project, @iteration)
  end

  def move_stories
    change_story_assignment
    redirect_to request.referer
  end

  def export
    @stories = @iteration.stories
    headers['Content-Type'] = "application/vnd.ms-excel"
    render :layout => false
  end
  alias export_tasks export

  protected
  def find_iteration
    @iteration = Iteration.find params[:id]
  end

  def change_story_assignment
    iteration = Iteration.find_by_id(params[:move_to])
    stories = Story.find(params[:selected_stories] || [])
    set_status_and_error_for(Story.assign_many_to_iteration(iteration, stories))
  end
end
