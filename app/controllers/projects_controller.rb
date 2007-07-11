class ProjectsController < ApplicationController
  before_filter :require_admin_privileges, :only => [:delete]
  skip_before_filter :check_authentication, :only => :audits
  popups :add_users, :update_users, :new, :edit
  

  def index
    @page_title = "Projects"
    if session[:current_user].admin?
        @projects = Project.find(:all, :order => 'name ASC')
    else
     	@projects = session[:current_user].projects
    end
  end
  
  def audits
    @audits = Audit.find(:all, :conditions => ["project_id = #{params[:id]} AND object = 'Story'"], :order => "created_at DESC")
    @project = Project.find(params[:id])
     render(:layout => false)
    @headers["Content-Type"] = "application/xml; charset=utf-8"
  end

  def new
    @page_title = "New Project"
    if @new_project = session[:new_project]
      session[:new_project] = nil
    else
      @new_project = Project.new
    end
  end

  def create
    project = Project.new(params[:new_project])
    if project.valid?
      project.save
      if params[:add_me] == '1'
        session[:current_user].projects << project
      end
      flash[:status] = "New project \"#{project.name}\" has been created."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      session[:new_project] = project
      redirect_to :controller => 'projects', :action => 'new'
    end
  end

  def add_users
    @page_title = "Add Users to Project Team"
    @available_users = User.find( :all,
      :order => 'last_name ASC, first_name ASC' ).select do |usr|
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
    user = User.find(params[:id])
    @project.users.delete(user)
    flash[:status] = "#{user.full_name} has been removed from the project."
    redirect_to :controller => 'users', :action => 'index',
                :project_id => @project.id
  end

  def delete
    project = Project.find(params[:id])
    project.destroy
    flash[:status] = "#{project.name} has been deleted."
    redirect_to :controller => 'projects', :action => 'index'
  end

  def edit
    if @project = session[:edit_project]
      session[:edit_project] = nil
    else
      @project = Project.find(params[:id])
    end
    @page_title = "Edit Project"
  end

  def update
    project = Project.find(params[:id])
    project.attributes = params[:project]
    if project.valid?
      project.save
      flash[:status] = "Project \"#{project.name}\" has been updated."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      session[:edit_project] = project
      redirect_to :controller => 'projects', :action => 'edit',
                  :id => project.id
    end
  end

  def my_projects_list
    @projects = session[:current_user].projects
    render :partial => 'my_projects_list'
  end
end