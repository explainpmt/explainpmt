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
    common_popup(project_releases_path(@project))
  end

  def edit
    common_popup(project_release_path(@project, @release))
  end

  def create
    @release = Release.new params[:release]
    @release.project = @project
    render :update do |page|
      if @release.save
        flash[:status] = "New Release \"#{@release.name}\" has been created."
        page.redirect_to project_releases_path(@project)
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@release.errors.full_messages[0]) %>"
      end
    end
  end

  def update
    render :update do |page|
      if @release.update_attributes(params[:release])
        flash[:status] = "Release \"#{@release.name}\" has been updated."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@release.errors.full_messages[0]) %>"
      end
    end
  end

  def destroy
    render :update do |page|
      @release.destroy
      flash[:status] = "#{@release.name} has been deleted."
      page.redirect_to project_releases_path(@project)
    end
  end
  
  def select_stories
    find_stories_not_in_release
    @stories = @other_stories
    render :update do |page|
      page.call 'showPopup', render(:partial => 'select_stories')
    end
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
     @other_stories = @project.stories.select { |s|
      s.release_id.nil?
    }
  end
  
  def change_story_release(release)
    stories = Story.find(params[:selected_stories]||[])
    set_status_and_error_for(Story.assign_many_to_release(release, stories))
  end

  def common_popup(url)
    render :update do |page|
      page.call 'showPopup', render(:partial => 'release_form', :locals => {:url => url})
    end
  end
end
