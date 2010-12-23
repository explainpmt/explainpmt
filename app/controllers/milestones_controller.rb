class MilestonesController < ApplicationController
  before_filter :find_milestone, :only => [:edit, :update, :show, :destroy]

  def index
    @future = current_project.milestones.future
    @recent = current_project.milestones.recent
  end

  def new
    @milestone = Milestone.new
  end

  def create
    @milestone = current_project.milestones.new(params[:milestone])
    if @milestone.save
      render_success("New Milestone \"#{@milestone.name}\" has been created.") { redirect_to project_milestones_path(current_project) }
    else
      render_errors(@milestone.errors.full_messages.to_sentence) { render :new }
    end
  end

  def update
    if @milestone.update_attributes(params[:milestone])
      render_success("Milestone \"#{@milestone.name}\" has been updated.") { redirect_to project_milestones_path(current_project) }
    else
      render_errors(@milestone.errors.full_messages.to_sentence) { render :edit }
    end
  end

  def destroy
    @milestone.destroy
    flash[:success] = "#{@milestone.name} has been deleted."
    redirect_to project_milestones_path(current_project)
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