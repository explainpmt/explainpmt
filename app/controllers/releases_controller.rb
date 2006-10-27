class ReleasesController < ApplicationController
  before_filter :require_current_project
  
  observer :release_observer
  
  def index
    list
    render :action => 'list'
  end

  def list
    @release_pages, @releases = paginate :releases, :per_page => 10, :order_by => 'release_date', :conditions => ['release_date > ? and project_id = ?', DateTime.now, @project.id]
  end

  def all
    @release_pages, @releases = paginate :releases, :per_page => 10, :order_by => 'release_date', :conditions => ['project_id = ?', @project.id]
    render :action => 'list'
  end

  def show
    @release = Release.find(params[:id])
  end

  def new
    @release = Release.new
  end

  def create
    @release = Release.new(params[:release])
    @release.project = @project
    if @release.save
      flash[:notice] = 'Release was successfully created.'
      redirect_to :action => 'list', :project_id => @project.id
    else
      render :action => 'new'
    end
  end

  def edit
    @release = Release.find(params[:id])
  end

  def update
    @release = Release.find(params[:id])
    if @release.update_attributes(params[:release])
      flash[:notice] = 'Release was successfully updated.'
      redirect_to :action => 'show', :id => @release, :project_id => @project.id
    else
      render :action => 'edit'
    end
  end

  def destroy
    Release.find(params[:id]).destroy
    redirect_to :action => 'list', :project_id => @project.id
  end
end
