class ReleasesController < ApplicationController
  before_filter :find_release, :except => [:index, :create, :new]

  def index
    @releases = current_project.releases
  end
  
  def show
    @stories = @release.stories
    find_stories_not_in_release
    @num_non_estimated_stories = (@release.stories.not_estimated_and_not_cancelled).size
    @release_points_completed = @release.stories.points_completed
    @release_points_non_completed = @release.stories.points_remaining
  end

  def new
    @release = Release.new
  end

  def create
    @release = current_project.releases.new(params[:release])
    if @release.save
      render_success("New Release \"#{@release.name}\" has been created.") { redirect_to project_releases_path(current_project) }
    else
      render_errors(@release.errors.full_messages.to_sentence) { render :new }
    end
  end

  def update
    if @release.update_attributes(params[:release])
      render_success("Release \"#{@release.name}\" has been updated.") { redirect_to project_releases_path(current_project) }
    else
      render_errors(@release.errors.full_messages.to_sentence) { render :edit }
    end
  end

  def destroy
    @release.destroy
    flash[:success] = "#{@release.name} has been deleted."
    redirect_to project_releases_path(current_project)
  end
  
  def select_stories
    find_stories_not_in_release
    @stories = @other_stories
    render :partial => "select_stories"
  end

  def assign_stories
    change_story_release(Release.find_by_id(params[:id]))
    redirect_to project_release_path(current_project, @release)
  end
  
  def remove_stories
    change_story_release(nil)
    redirect_to project_release_path(current_project, @release)
  end

  protected

  def find_release
    @release = Release.find params[:id]
  end
  
  def find_stories_not_in_release
    @other_stories = current_project.stories.select { |s| s.release_id.nil? }
  end
  
  def change_story_release(release)
    stories = Story.find(params[:selected_stories]||[])
    set_status_and_error_for(Story.assign_many_to_release(release, stories))
  end

end
