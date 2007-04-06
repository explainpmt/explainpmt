##############################################################################
# eXPlain Project Management Tool
# Copyright (C) 2005  John Wilger <johnwilger@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##############################################################################


# All actions on this controller require the user to have administrative
# privileges.
class ProjectsController < ApplicationController
  before_filter :require_admin_privileges, :only => [:delete]
  skip_before_filter :check_authentication, :only => :audits
  popups :add_users, :update_users, :new, :edit
  

  # Lists all of the projects that exist on the system.
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
  # Displays a form for creating a new project.
  def new
    @page_title = "New Project"
    if @new_project = session[:new_project]
      session[:new_project] = nil
    else
      @new_project = Project.new
    end
  end

  # Creates a new project based on the information submitted from the #new
  # action.
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

  # Displays a form which allows existing user accounts to be added to the
  # project team. Only users who do not already belong to the team will be
  # displayed.
  def add_users
    @page_title = "Add Users to Project Team"
    @available_users = User.find( :all,
      :order => 'last_name ASC, first_name ASC' ).select do |usr|
      !usr.projects.include?(@project)
    end
  end

  # Adds the users identified by their id's in the 'selected_users' request
  # parameter to the project.
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

  # Removes the user identified by the 'id' request parameter from the project.
  def remove_user
    user = User.find(params[:id])
    @project.users.delete(user)
    flash[:status] = "#{user.full_name} has been removed from the project."
    redirect_to :controller => 'users', :action => 'index',
                :project_id => @project.id
  end

  # Deletes the project identified by the 'id' request parameter form the
  # system.
  def delete
    project = Project.find(params[:id])
    project.destroy
    flash[:status] = "#{project.name} has been deleted."
    redirect_to :controller => 'projects', :action => 'index'
  end

  # Displays a form to edit the information for the project identified by the
  # 'id' request parameter.
  def edit
    if @project = session[:edit_project]
      session[:edit_project] = nil
    else
      @project = Project.find(params[:id])
    end
    @page_title = "Edit Project"
  end

  # Updates the project identified by the 'id' request parameter with the
  # information submitted from the #edit action.
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

  # Renders an ordered list of projects (with links) to which the current user
  # belongs
  def my_projects_list
    @projects = session[:current_user].projects
    render :partial => 'my_projects_list'
  end
end