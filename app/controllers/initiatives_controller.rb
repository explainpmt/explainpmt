class InitiativesController < ApplicationController
  before_filter :find_initiative, :except => [:index, :create, :new]

  def index
    @initiatives = current_project.initiatives
  end

  def new
    @initiative = Initiative.new
  end

  def create
    @initiative = Initiative.new params[:initiative]
    @initiative.project = current_project
    
    if @initiative.save
      render_success("New initiative \"#{@initiative.name}\" has been created.") { redirect_to project_initiatives_path(current_project) }
    else
      render_errors(@initiative.errors.full_messages.to_sentence) { render :new }
    end
  end

  def update
    if @initiative.update_attributes(params[:initiative])
      render_success("Initiative \"#{@initiative.name}\" has been updated.") { redirect_to project_initiatives_path(current_project) }
    else
      render_errors(@initiative.errors.full_messages.to_sentence) { render :edit }
    end
    
  end

  def destroy
    @initiative.destroy
    flash[:success] = "#{@initiative.name} has been deleted."
    redirect_to project_initiatives_path(current_project)
  end

  protected

  def find_initiative
    @initiative = Initiative.find params[:id]
  end
end
