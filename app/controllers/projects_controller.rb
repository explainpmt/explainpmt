class ProjectsController < ApplicationController
  before_filter :require_admin_privileges, :only => [:delete]
  skip_before_filter :check_authentication, :only => :audits
  popups :add_users, :update_users, :new, :edit
  
  def index
    @page_title = "Projects"
    @projects = current_user.admin? ? Project.find(:all, :order => 'name ASC') : current_user.projects
  end
  
  def audits
    @audits = Audit.find(:all, :conditions => ["project_id = #{params[:id]} AND object = 'Story'"], :order => "created_at DESC")
    @project = Project.find params[:id]
    render :layout => false
    @headers["Content-Type"] = "application/xml; charset=utf-8"
  end

  def new
    @page_title = "New Project"
    @project = Project.new
  end

  def create
    @project = Project.new params[:project]
    if @project.save
      current_user.projects << @project if params[:add_me] == '1'
      flash[:status] = "New project \"#{@project.name}\" has been created."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      render :action => "new", :layout => "popup"
    end
  end

  def add_users
    @page_title = "Add Users to Project Team"
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

  def delete
    project = Project.find params[:id]
    project.destroy
    flash[:status] = "#{project.name} has been deleted."
    redirect_to :controller => 'projects', :action => 'index'
  end

  def edit
    @project = Project.find params[:id]
    @page_title = "Edit Project"
  end

  def update
    @project = Project.find params[:id]
    @project.attributes = params[:project]
    if @project.save
      flash[:status] = "Project \"#{@project.name}\" has been updated."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      render :action => "edit" , :layout => 'popup'
    end
  end

  def my_projects_list
    @projects = current_user.projects
    render :partial => 'my_projects_list'
  end
end