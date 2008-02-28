class AcceptancetestsController < ApplicationController
  before_filter :require_current_project
  
  def index
    @acceptancetests = @project.acceptancetests
  end

  def new
    render :update do |page|
      url = params[:story_id] ? project_story_acceptancetests_path(@project, Story.find(params[:story_id])) : project_acceptancetests_path(@project)
      page.call 'showPopup', render(:partial => 'acceptancetest_form', :locals => {:url => url})
      page.call 'autoFocus', "acceptancetest_name", 500
    end 
  end

  def create
    acceptancetest = Acceptancetest.new params[:acceptancetest]
    story = Story.find params[:story_id] if params[:story_id]
    acceptancetest.project = @project
    acceptancetest.story = story if story
    render :update do |page|
      if acceptancetest.save
        flash[:status] = "New Acceptance Test \"#{acceptancetest.name}\" has been created."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html acceptancetest.errors.full_messages[0]
      end
    end    
  end

  def export
    headers['Content-Type'] = "application/vnd.ms-excel" 
    render :layout => false
  end
  
  def show
    @acceptancetest = Acceptancetest.find params[:id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'acceptancetests/show')
      page.call 'autoFocus', "acceptancetest_name", 500
    end     
  end

  def edit
    @acceptancetest = Acceptancetest.find params[:id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'acceptancetest_form', :locals => {:url => project_acceptancetest_path(@project, @acceptancetest)})
      page.call 'autoFocus', "acceptancetest_name", 500
    end 
  end
  
  def update
    acceptancetest = Acceptancetest.find params[:id]
    render :update do |page|
      if acceptancetest.update_attributes(params[:acceptancetest])
        flash[:status] = "Acceptance Test \"#{acceptancetest.name}\" has been updated."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html acceptancetest.errors.full_messages[0]
      end
    end
  end
  
  def destroy
    acceptancetest = Acceptancetest.find params[:id]
    render :update do |page|
      if acceptancetest.destroy
        flash[:status] = "Acceptance Test \"#{acceptancetest.name}\" has been deleted."
        page.call 'location.reload'
      end
    end
  end

  def clone_acceptance
    acceptancetest = Acceptancetest.find(params[:id]).clone
    acceptancetest.name = "Clone:" + acceptancetest.name
    acceptancetest.save
    render :update do |page|
      page.call 'location.reload'
    end 
  end

end
