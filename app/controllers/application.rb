class ApplicationController < ActionController::Base
  layout :choose_layout
  include CurrentUser
  before_filter :check_authentication
  before_filter :set_selected_project
  before_filter :require_team_membership
  
  protected
  
  def set_selected_project
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
  end
  
  def check_authentication
    unless current_user.kind_of?(User)
      session[:return_to] = request.request_uri
      flash[:status] = "Please log in, and we'll send you right along."
      redirect_to :controller => 'users', :action => 'login'
      return false
    end
  end
  
  def require_admin_privileges
    unless current_user.admin?
      flash[:error] = "You must be logged in as an administrator to perform " +
                      "the requested action."
      redirect_to :controller => 'error', :action => 'index'
      return false
    end
  end
  
  def require_team_membership
    if @project and !current_user.admin?
      unless User.find(current_user.id).projects.include?(@project)
        flash[:error] = 'You do not have permission to access the project, ' +
                        'because you are not part of the project team.'
        redirect_to :controller => 'error', :action => 'index'
        return false
      end
    end
  end
  
  def self.popups(*popup_actions)
    @@popups ||= {}
    @@popups[controller_name] ||= []
    popup_actions.each do |a|
      @@popups[controller_name] << a.to_sym
    end
  end
  
  def choose_layout
    @@popups ||= {}
    @@popups[controller_name] ||= []
    if @@popups[controller_name].include?(action_name.to_sym)
      'layouts/popup'
    else
      'layouts/main'
    end
  end
  
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
  
  def register_referer
    unless request.env['HTTP_REFERER'].blank?
      session[:referer] = request.env['HTTP_REFERER']
    end
  end
  
  def redirect_to_referer
    if session[:referer]
      redirect_to session[:referer]
      session[:referer] = nil
      true
    else
      false
    end
  end
end