class ProjectsController < ApplicationController
  skip_before_filter :check_authentication, :only => :audits
  skip_before_filter :require_current_project

  def index
    paging = {:size => 50, :current => params[:page]}
    @projects = current_user.admin? ? Project.find(:all, :order => 'name ASC', :page => paging) : current_user.projects.find(:all, :page => paging)
  end

  def show
    redirect_to project_dashboard_path(Project.find(params[:id]))
  end

  def team
    @project = Project.find params[:id]
    @users = @project.users.find(:all, :page => {:size => 20, :current => params[:page]})
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

  def add_users
    @project = Project.find params[:id]
    @available_users = @project.users_available_for_addition
    render :update do |page|
      page.call 'showPopup', render(:partial => 'add_users')
    end
  end

  def update_users
    @project = Project.find params[:id]
    users_added = []
    (params[:selected_users] || []).each do |uid|
      user = User.find_by_id(uid)
      if user
        @project.users << user
        users_added << user.full_name
      end
    end
    flash[:status] = "The following users were added to the project: " + users_added.join(', ') unless users_added.empty?
    redirect_to team_project_path(@project)
  end

  def audits
    @audits = Audit.find(:all, :conditions => ["project_id = #{params[:id]} AND object = 'Story'"], :order => "created_at DESC")
    @project = Project.find params[:id]
    render :layout => false
  end

end