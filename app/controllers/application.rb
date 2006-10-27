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

# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  model :user
  model :project
  model :iteration
  model :story
  model :milestone

  helper :sort
  helper :collection_table
  
  layout :choose_layout
  before_filter :check_authentication
  before_filter :set_selected_project
  before_filter :require_team_membership
  
  protected

  # Used as a before_filter to instantiate the @project instance variable based
  # on the 'project_id' request parameter. This ensures that @project is always
  # available when performing actions that should occur within the context of a
  # single project.
  def set_selected_project
    if @params['project_id']
      @project = Project.find(@params['project_id'])
    else
      @project = nil
    end
  end
  
  # Used as a before_filter to ensure that the 'current_user' session variable
  # contians a valid User (or descendent class) object. Otherwise the user is
  # redirected to the login page. If redirected, the 'return-to' session
  # variable will contain the path to the page the user was originally trying to
  # access.
  def check_authentication
    unless @session[:current_user].kind_of?(User) or
      self.class == SessionController

      @session[:return_to] = @request.request_uri
      flash[:status] = "Please log in, and we'll send you right along."
      redirect_to :controller => 'session', :action => 'login'
      return false
    end
  end

  # This method can be used as a before_filter for actions which should require
  # admin privileges to perform. If the user tries to perform an action which
  # triggers this filter, and they do not have admin privileges, they will be
  # redirected to the error page with an error message saying that they must log
  # in as an administrator to perform the requested action.
  def require_admin_privileges
    unless @session[:current_user].admin?
      flash[:error] = "You must be logged in as an administrator to perform " +
                      "the requested action."
      redirect_to :controller => 'error', :action => 'index'
      return false
    end
  end

  # Used as a before_filter to ensure that the currently logged in user is
  # allowed to access the current project by determining whether he is an
  # administrator or if he is on the project team.
  def require_team_membership
    if @project and !@session[:current_user].admin?
      unless User.find(@session[:current_user].id).projects.include?(@project)
        flash[:error] = 'You do not have permission to access the project, ' +
                        'because you are not part of the project team.'
        redirect_to :controller => 'error', :action => 'index'
        return false
      end
    end
  end

  # Used in the controller class definitions to specify which actions should be
  # rendered using the popup layout.
  def self.popups(*popup_actions)
    @@popups ||= {}
    @@popups[controller_name] ||= []
    popup_actions.each do |a|
      @@popups[controller_name] << a.to_sym
    end
  end

  # Chooses whether to use the regular page layout or the popup page layout
  # depending on whether the action is listed as one of the controller's popup
  # views.
  def choose_layout
    @@popups ||= {}
    @@popups[controller_name] ||= []
    if @@popups[controller_name].include?(action_name.to_sym)
      'layouts/popup'
    else
      'layouts/main'
    end
  end

  # Used as a before_filter to ensure that a project is selected. If no project
  # is selected, the user is sent to an error page.
  def require_current_project
    unless @project
      @@popups ||= {}
      @@popups[controller_name] ||= []
      if @@popups[controller_name].include? action_name.to_sym
        redirect_to :controller => 'error', :action => 'popup'
      else
        redirect_to :controller => 'error', :action => 'index'
      end
      flash[:error] = "You attempted to access a view that requires a " +
                      "project to be selected, but no project id was set in " +
                      "your request."
      return false
    end
  end
  
  # Saves the HTTP_REFERER into the session
  # Used in conjunction with #return_to_referer
  def register_referer
    @session[:referer] = request.env['HTTP_REFERER'] unless
                         request.env['HTTP_REFERER'].blank?
  end
  
  # Redirects the user back to the registered referer, and deletes the referer
  # Returns false if no referer was registered
  # Used in conjunction with #register_referer
  def redirect_to_referer
    if session[:referer]
      redirect_to session[:referer]
      session[:referer] = nil
      return true
    else
      return false
    end
  end
end


