class InitiativesController < ApplicationController
  before_filter :require_current_project
  before_filter :find_initiative, :except => [:index, :create, :new]
  
  def index
    @initiatives = @project.initiatives
  end
  
  def new
    common_popup(project_initiatives_path(@project))
  end
  
  def edit
    common_popup(project_initiative_path(@project, @initiative))
  end
  
  def create
    initiative = Initiative.new params[:initiative]
    initiative.project = @project
    render :update do |page|
      if initiative.save
        flash[:status] = "New initiative \"#{initiative.name}\" has been created."
        page.redirect_to project_initiatives_path(@project)
      else
        page[:flash_notice].replace_html initiative.errors.full_messages[0]
      end
    end    
  end
  
  def update
    render :update do |page|
      if @initiative.update_attributes(params[:initiative])
        flash[:status] = "initiative \"#{@initiative.name}\" has been updated."
        page.redirect_to project_initiatives_path(@project)
      else
        page[:flash_notice].replace_html @initiative.errors.full_messages[0]
      end
    end
  end
     
  def destroy
    @initiative.destroy
    flash[:status] = "#{@initiative.name} has been deleted."
    redirect_to project_initiatives_path(@project)
  end
  
  protected
  def common_popup(url)
    render :update do |page|
      page.call 'showPopup', render(:partial => 'initiative_form', :locals => {:url => url})
      page.call 'autoFocus', "project_name", 500
    end 
  end
  
  def find_initiative
    @initiative = Initiative.find params[:id]
  end
  
end
