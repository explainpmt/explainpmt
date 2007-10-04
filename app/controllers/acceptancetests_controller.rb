class AcceptancetestsController < ApplicationController
  before_filter :require_current_project
  popups :new, :create, :edit, :update, :show , :export, :new_acceptance_for_story, :clone_acceptancetest
  
  def index
    @list = @project.acceptancetests
  end

  def edit
    @acceptancetest = Acceptancetest.find params[:id]
  end
  
  def new
    @acceptancetest = Acceptancetest.new
  end

  def create
    @acceptancetest = Acceptancetest.new params[:acceptancetest]
    @acceptancetest.project = @project
    if @acceptancetest.save
      flash[:status] = "Acceptancetest \"#{@acceptancetest.name}\" has been saved."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      render :action => "new", :layout => "popup"
    end
  end
  
  def update
    @acceptancetest = Acceptancetest.find params[:id]
    if @acceptancetest.update_attributes params[:acceptancetest]
      flash[:status] = "Changes to \"#{@acceptancetest.name}\" have been been saved."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      render :action => "edit", :layout => "popup"
    end
  end
  
  def show
    @acceptancetest = Acceptancetest.find params[:id]
  end
   
  def delete
    acceptancetest_selected = Acceptancetest.find params[:id]
    acceptancetest_selected.destroy
    flash[:status] = "Acceptancetest \"#{acceptancetest_selected.name}\" has been deleted."
    redirect_to :action => 'index', :project_id => @project.id
  end
  
  def export
    headers['Content-Type'] = "application/vnd.ms-excel" 
    @list = @project.acceptancetests
    render :layout => false
  end
  
  
  def clone_acceptancetest
    @acceptancetest = Acceptancetest.find params[:id]
	  @story = Story.find(params[:story_id]) if params[:story_id]
    @page_title = "Clone Acceptancetest"
  end
  
  def index
    @stories = @project.stories
    @acceptancetests = @project.acceptancetests
    @page_title = "Acceptance Tests"
  end
  
  def new_acceptance_for_story
    @acceptancetest = Acceptancetest.new
    @story = Story.find params[:story_id]
  end
  
  def delete_from_story
    acceptance = Acceptancetest.find params[:id]
    acceptance.destroy
    flash[:status] = "#{mymodel.name} \"#{acceptance.name}\" has been deleted."
    redirect_to :controller => 'stories', :action => 'show', 
                  :id => acceptance.story_id,
                  :project_id => @project.id
  end

end
