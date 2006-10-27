=begin License
  eXPlain Project Management Tool
  Copyright (C) 2005  John Wilger <johnwilger@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
=end LICENSE

class UsersController < ApplicationController
  before_filter :require_admin_privileges, :except => [:index, :project]

  # If the 'project_id' request parameter is set, this will display the
  # project's team members. Otherwise, it shows all users on the system.
  def index
    if @project
      @page_title = "Project Team"
      @users = @project.users
      render 'users/project'
    else
      @page_title = "System Users"
      @users = User.find_all(nil, 'last_name ASC, first_name ASC')
    end
  end

  # Displays the form to create a new user account.
  def new
    @page_title = "New User"
    if @session[:new_user]
      @user = @session[:new_user]
      @session[:new_user] = nil
    else
      register_referer
      @user = User.new
    end
  end

  # Displays the form to edit a user account.
  def edit
    @user = User.find(@params['id'])
    @page_title = @user.full_name
    if @session[:edit_user]
      @user = @session[:edit_user]
      @session[:edit_user] = nil
    else
      register_referer
    end
  end

  # Creates a new user account based o information submitted from the #new
  # action.
  def create
    user = User.new(@params['user'])
    if user.valid?
      user.save
      flash[:status] = "User account for #{user.full_name} has been created."

      if @project
        @project.users << user
        flash[:status] = "User account for #{user.full_name} has been " +
                          "created and added to the project team."
      end
      
      unless redirect_to_referer
        redirect_to :controller => 'dashboard'
      end
    else
      @session[:new_user] = user
      if @project
        redirect_to(:controller => 'users', :action => 'new',
                    :project_id => @project.id)
      else
        redirect_to :controller => 'users', :action => 'new'
      end
    end
  end

  # Updates a user account with the information submitted from the #edit action.
  def update
    user = User.find(@params['id'])
    original_password = user.password
    user.attributes = @params['user']
    if @params['user']['password'] == ''
      user.password = user.password_confirmation = original_password
    end
    if user == @session[:current_user] and !user.admin? and
      @session[:current_user].admin?

      user.admin = 1
      flash[:error] = "You can not remove admin privileges from yourself."
    end
    if user.valid?
      user.save
      flash[:status] = "User account for #{user.full_name} has been updated."
      unless redirect_to_referer
        redirect_to :controller => 'dashboard'
      end
    else
      @session[:edit_user] = user
      redirect_to(:controller => 'users', :action => 'edit', :id => user.id)
    end
  end

  # Deletes the user account identified by the 'id' request parameter.
  def delete
    user = User.find(@params['id'])
    if user == @session[:current_user]
      flash[:error] = "You can not delete your own account."
    else
      user.destroy
      flash[:status] = "User account for #{user.full_name} has been deleted."
    end
    redirect_to :controller => 'users', :action => 'index'
  end

  protected

  # Overrides the ApplicationController#require_admin_privileges method so that
  # a non-admin user can edit their own account details.
  def require_admin_privileges
    case action_name
    when 'edit','update'
      super if @params['id'].to_i != @session[:current_user].id
    else
      super
    end
  end
end
