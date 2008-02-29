class ProjectsController < ApplicationController
  skip_before_filter :check_authentication, :only => :audits
  skip_before_filter :require_current_project
  
  def index
    @projects = current_user.admin? ? Project.find(:all, :order => 'name ASC') : current_user.projects
  end
  
  def team
    @project = Project.find params[:id]
    @users = @project.users
  end
  
  def new
    render :update do |page|
      page.call 'showPopup', render(:partial => 'project_form', :locals => {:url => projects_path})
    end
  end
  
  def create
    @project = Project.new params[:project]
    render :update do |page|
      if @project.save
        current_user.projects << @project if params[:add_me] == '1'
        flash[:status] = "New project \"#{@project.name}\" has been created."
        page.redirect_to projects_path
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@project.errors.full_messages[0]) %>"
      end
    end
  end
  
  def edit
    @project = Project.find params[:id]
    render :update do |page|
      page.call 'showPopup', render(:partial => 'project_form', :locals => {:url => project_path(@project)})
    end
  end
  
  def update
    project = Project.find params[:id]
    render :update do |page|
      if project.update_attributes(params[:project])
        flash[:status] = "Project \"#{project.name}\" has been updated."
        page.redirect_to projects_path
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@project.errors.full_messages[0]) %>"
      end
    end
  end
  
  def destroy
    project = Project.find params[:id]
    project.destroy
    flash[:status] = "#{project.name} has been deleted."
    redirect_to projects_path
  end
 
  
  
  
  
  def audits
    @audits = Audit.find(:all, :conditions => ["project_id = #{params[:id]} AND object = 'Story'"], :order => "created_at DESC")
    @project = Project.find params[:id]
    render :layout => false
  end
  
  
  def add_users
    @available_users = User.find( :all, :order => 'last_name ASC, first_name ASC' ).select do |usr|
      !usr.projects.include?(@project)
    end
  end

  def update_users
    params[:selected_users] ||= []
    users_added = []
    users_not_added = []
    params[:selected_users].each do |uid|
      uid = uid.to_i
      user = User.find(uid)
      if user.valid?
        @project.users << user
        users_added << user.full_name
      else
        users_not_added << user.full_name
      end
    end
    @project.save
    if users_added.size > 0
      flash[:status] = "The following users were added to the project: " +
        users_added.join(', ')
    end
    if users_not_added.size > 0
      flash[:error] = "The following users could not be added to the " +
        "project, because there is a problem with their " +
        "account: #{users_not_added.join(', ')}"
    end
    render :template => 'layouts/refresh_parent_close_popup'
  end

  def remove_user
    user = User.find params[:id]
    @project.users.delete(user)
    flash[:status] = "#{user.full_name} has been removed from the project."
    redirect_to :controller => 'users', :action => 'index',
      :project_id => @project.id
  end

end