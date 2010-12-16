class AcceptanceTestsController < ApplicationController
  before_filter :find_acceptance, :except => [:index, :new, :create, :export, :assign]

  def index
    @acceptance_tests = @project.acceptance_tests
  end

  def new
    @acceptance_test = AcceptanceTest.new
  end

  def show
  end

  def edit
  end

  def create
    @acceptance_test = AcceptanceTest.new params[:acceptance_test]
    @acceptance_test.project = @project
    @acceptance_test.story_id = params[:story_id] if params[:story_id]
    
    respond_to do |format|
      if @acceptance_test.save
        msg = "New Acceptance Test \"#{@acceptance_test.name}\" has been created."
        format.html { 
          flash[:success] = msg
          redirect_to acceptance_tests_path
        }
        format.js { render :json => { :message => msg } }
      else
        msg = @acceptance_test.errors.full_messages.to_sentence
        format.html {
          flash[:error] = msg
          render :new
        }
        format.js { render :json => { :errors => msg }}
      end
    end
  end

  def update
    if @acceptance_test.update_attributes(params[:acceptance_test])
      flash[:status] = "Acceptance Test \"#{@acceptance_test.name}\" has been updated."
      redirect_to project_acceptance_tests_path(@project)
    else
      render :text => @acceptance_test.errors.full_messages.to_sentence
    end
  end

  def destroy
    @acceptance_test.destroy
    flash[:status] = "Acceptance Test \"#{@acceptance_test.name}\" has been deleted."
  end

  def clone_acceptance
    @acceptance_test.clone!
    redirect_to project_acceptance_tests_path(@project)
  end

  def export
    headers['Content-Type'] = "application/vnd.ms-excel"
    render :layout => false
  end

  def assign
    story = Story.find_by_id(params[:move_to])
    acceptance_tests = AcceptanceTest.find(params[:selected_acceptance_tests] || [])
    set_status_and_error_for(AcceptanceTest.assign_many_to_story(story, acceptance_tests))
    redirect_to project_acceptance_tests_path(@project)
  end

  protected

  def find_acceptance
    @acceptance_test = AcceptanceTest.find params[:id]
  end
end