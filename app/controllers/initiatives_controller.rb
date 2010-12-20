class InitiativesController < ApplicationController
  before_filter :find_initiative, :except => [:index, :create, :new]

  def index
    @initiatives = @project.initiatives
  end

  def new
    @initiative = Initiative.new
  end

  def create
    @initiative = Initiative.new params[:initiative]
    @initiative.project = @project
    respond_to do |format|
      if @initiative.save
        msg = "New initiative \"#{@initiative.name}\" has been created."
        format.html {
          flash[:success] = msg
          redirect_to project_initiatives_path(@project)
        }
        format.js { render :json => { :message => msg } }
      else
        msg = @initiative.errors.full_messages.to_sentence
        format.html {
          flash[:error] = msg
          render :new
        }
        format.js { render :json => { :errors => msg } }
      end
    end
  end

  def update
    if @initiative.update_attributes(params[:initiative])
      flash[:success] = "initiative \"#{@initiative.name}\" has been updated."
      redirect_to project_initiatives_path(@project)
    else
      flash[:error] = @initiative.errors.full_messages.to_sentence
    end
  end

  def destroy
    @initiative.destroy
    flash[:success] = "#{@initiative.name} has been deleted."
    redirect_to project_initiatives_path(@project)
  end

  protected

  def find_initiative
    @initiative = Initiative.find params[:id]
  end
end
