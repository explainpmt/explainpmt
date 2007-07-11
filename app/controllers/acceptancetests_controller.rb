class AcceptancetestsController < ApplicationController
  include CrudActions
  
  before_filter :require_current_project
  popups :new, :create, :edit, :update, :show , :export, :new_acceptance_for_story, :clone_acceptancetest
  
  def mymodel
    Acceptancetest
  end
  
  def clone_acceptancetest
    @object = mymodel.find params[:id]
	  @story = Story.find(params[:story_id]) if params[:story_id]
    @page_title = "Clone #{mymodel}"
  end
  
  def index
    @stories = @project.stories
    @acceptancetests = mymodel.find_all_acceptance_tests @project.id
    @page_title = "Acceptance Tests"
  end
  
  def new_acceptance_for_story
    @object = Acceptancetest.new
    @story = Story.find params[:story_id]
  end
  
  def delete_from_story
    myobject = mymodel.find params[:id]
    myobject.destroy
    flash[:status] = "#{mymodel.name} \"#{myobject.name}\" has been deleted."
    redirect_to :controller => 'stories', :action => 'show', 
                  :id => myobject.story_id,
                  :project_id => @project.id
  end

end
