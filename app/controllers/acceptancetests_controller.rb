class AcceptancetestsController < ApplicationController
  include CrudActions
  
  before_filter :require_current_project
  popups :new, :create, :edit, :update, :show , :export, :new_acceptance_for_story, :clone_acceptancetest
  
  def mymodel
    Acceptancetest
  end
  
  def clone_acceptancetest
	@object = session[:object] || mymodel.find(params[:id])
	if(params[:story_id])
		@story = Story.find(params[:story_id])
	end
    session[:object] = nil
    @page_title = "Clone #{mymodel}"
  end
  
  def index
    @stories = @project.stories
    @acceptancetests = mymodel.find(:all, :order => mymodel.editlist_order, :conditions => [ "project_id = (?)", @project.id] )
    @page_title = "Acceptance Tests"
  end
  
  def new_acceptance_for_story
    @object = session[:object] || Acceptancetest.new
    session[:object] = nil
    @story = Story.find(params[:story_id])
  end
  
  def delete_from_story
    myobject = mymodel.find(params[:id])
    myobject.destroy
    flash[:status] = "#{mymodel.name} \"#{myobject.name}\" has been deleted."
    redirect_to :controller => 'stories', :action => 'show', 
                  :id => myobject.story_id,
                  :project_id => @project.id
  end

end
