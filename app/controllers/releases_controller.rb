class ReleasesController < ApplicationController
  before_filter :find_release, :except => [:index, :create, :new]

  def index
    @releases = @project.releases
  end
  
  def show
    @stories = @release.stories
    find_stories_not_in_release
    @num_non_estimated_stories = (@release.stories.not_estimated_and_not_cancelled).size
    @release_points_completed = @release.stories.points_completed
    @release_points_non_completed = @release.stories.points_not_completed
  end

  def new
    @release = Release.new
  end

  def edit
  end

  def create
    @release = @project.releases.new params[:release]
    respond_to do |format|
      if @release.save
        msg = "New Release \"#{@release.name}\" has been created."
        format.html {
          flash[:success] = msg
          redirect_to project_releases_path(@project)
        }
        format.js { render :json => { :message => msg } }
      else
        msg = @release.errors.full_messages.to_sentence
        format.html {
          flash[:errors] = msg
          render :new
        }
        format.js { render :json => { :errors => msg } }
      end
    end
  end

  def update
    respond_to do |format|
      if @release.update_attributes(params[:release])
        msg = "Release \"#{@release.name}\" has been updated."
        format.html {
          flash[:success] = msg
          redirect_to project_releases_path(@project)
        }
        format.js { render :json => { :message => msg } }
      else
        msg = @release.errors.full_messages.to_sentence
        format.html {
          flash[:errors] = msg
          render :new
        }
        format.js { render :json => { :errors => msg } }
      end
    end
  end

  def destroy
    @release.destroy
    flash[:success] = "#{@release.name} has been deleted."
    redirect_to project_releases_path(@project)
  end
  
  def select_stories
    find_stories_not_in_release
    @stories = @other_stories
    render :partial => "select_stories"
  end

  def assign_stories
    change_story_release(Release.find_by_id(params[:id]))
    redirect_to project_release_path(@project, @release)
  end
  
  def remove_stories
    change_story_release(nil)
    redirect_to project_release_path(@project, @release)
  end

  protected

  def find_release
    @release = Release.find params[:id]
  end
  
  def find_stories_not_in_release
    @other_stories = @project.stories.select { |s| s.release_id.nil? }
  end
  
  def change_story_release(release)
    stories = Story.find(params[:selected_stories]||[])
    set_status_and_error_for(Story.assign_many_to_release(release, stories))
  end

end
