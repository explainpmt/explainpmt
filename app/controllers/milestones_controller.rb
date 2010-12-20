class MilestonesController < ApplicationController
  before_filter :find_milestone, :only => [:edit, :update, :show, :destroy]

  def index
    @future = @project.milestones.future
    @recent = @project.milestones.recent
  end

  def new
    @milestone = Milestone.new
  end

  def create
    @milestone = Milestone.new params[:milestone]
    @milestone.project = @project
    
    respond_to do |format|
      if @milestone.save
        msg = "New Milestone \"#{@milestone.name}\" has been created."
        format.html { 
          flash[:success] = msg
          redirect_to project_milestones_path(@project)
        }
        format.js { render :json => { :message => msg } }
      else
        msg = @milestone.errors.full_messages.to_sentence
        format.html {
          flash[:error] = msg
          render :new
        }
        format.js { render :json => { :errors => msg }}
      end
    end
  end

  def update
    respond_to do |format|
      if @milestone.update_attributes(params[:milestone])
        msg = "Milestone \"#{@milestone.name}\" has been updated."
        format.html { 
          flash[:success] = msg
          redirect_to project_milestones_path(@project)
        }
        format.js { render :json => { :message => msg } }
      else
        msg = @milestone.errors.full_messages.to_sentence
        format.html {
          flash[:error] = msg
          render :edit
        }
        format.js { render :json => { :errors => msg }}
      end
    end
  end

  def destroy
    @milestone.destroy
    flash[:success] = "#{@milestone.name} has been deleted."
    redirect_to project_milestones_path(@project)
  end

  def show_all
    # render :update do |page|
    #   page[:recent].replace_html :inline => "<%= past_milestones %>"
    #   page[:recent_title].replace_html :inline => "All Milestones <small>(<%= link_to_show_recent_milestones %>)</small>"
    # end
  end

  def show_recent
    # render :update do |page|
    #   page[:recent].replace_html :inline => "<%= recent_milestones %>"
    #   page[:recent_title].replace_html :inline => "Recent Milestones <small>(<%= link_to_show_all_milestones %>)</small>"
    # end
  end

  protected

  def find_milestone
    @milestone = Milestone.find params[:id]
  end

end