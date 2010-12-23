class AcceptanceTestsController < ApplicationController
  before_filter :find_acceptance, :except => [:index, :new, :create, :export, :assign]

  def index
    @acceptance_tests = current_project.acceptance_tests
  end

  def new
    @acceptance_test = AcceptanceTest.new
  end

  def create
    @acceptance_test = AcceptanceTest.new params[:acceptance_test]
    @acceptance_test.project = current_project
    @acceptance_test.story_id = params[:story_id] if params[:story_id]
    
    if @acceptance_test.save
      render_success("New Acceptance Test \"#{@acceptance_test.name}\" has been created.") { redirect_to project_acceptance_tests_path(current_project) }
    else
      render_errors(@acceptance_test.errors.full_messages.to_sentence) { render :new }
    end
  end

  def update
    if @acceptance_test.update_attributes(params[:acceptance_test])
      render_success("Acceptance Test \"#{@acceptance_test.name}\" has been updated.") { redirect_to project_acceptance_tests_path(current_project) }
    else
      render_errors(@acceptance_test.errors.full_messages.to_sentence) { render :edit }
    end
  end

  def destroy
    @acceptance_test.destroy
    flash[:status] = "Acceptance Test \"#{@acceptance_test.name}\" has been deleted."
    redirect_to project_acceptance_tests_path(current_project)
  end

  def clone_acceptance
    @acceptance_test.clone!
    redirect_to project_acceptance_tests_path(current_project)
  end

  def export
    headers['Content-Type'] = "application/vnd.ms-excel"
    render :layout => false
  end

  def assign
    story = Story.find_by_id(params[:move_to])
    acceptance_tests = AcceptanceTest.find(params[:selected_acceptance_tests] || [])
    set_status_and_error_for(AcceptanceTest.assign_many_to_story(story, acceptance_tests))
    redirect_to project_acceptance_tests_path(current_project)
  end

  protected

  def find_acceptance
    @acceptance_test = AcceptanceTest.find params[:id]
  end
end